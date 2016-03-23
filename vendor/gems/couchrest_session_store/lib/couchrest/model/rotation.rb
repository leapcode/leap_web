module CouchRest
  module Model
    module Rotation
      extend ActiveSupport::Concern
      include CouchRest::Model::DatabaseMethod

      included do
        use_database_method :rotated_database_name
      end

      def create(*args)
        super(*args)
      rescue CouchRest::NotFound => exc
        raise storage_missing(exc)
      end

      def update(*args)
        super(*args)
      rescue CouchRest::NotFound => exc
        raise storage_missing(exc)
      end

      def destroy(*args)
        super(*args)
      rescue CouchRest::NotFound => exc
        raise storage_missing(exc)
      end

      private

      # returns a special 'storage missing' exception when the db has
      # not been created. very useful, since this happens a lot and a
      # generic 404 is not that helpful.
      def storage_missing(exc)
        if exc.http_body =~ /no_db_file/
          CouchRest::StorageMissing.new(exc.response, database)
        else
          exc
        end
      end

      public

      module ClassMethods
        #
        # Set up database rotation.
        #
        # base_name -- the name of the db before the rotation number is
        # appended.
        #
        # options -- one of:
        #
        # * :every -- frequency of rotation
        # * :expiration_field - what field to use to determine if a
        #                       document is expired.
        # * :timestamp_field - alternately, what field to use for the
        #                      document timestamp.
        # * :timeout -- used to expire documents with only a timestamp
        #               field (in minutes)
        #
        def rotate_database(base_name, options={})
          @rotation_base_name = base_name
          @rotation_every = (options.delete(:every) || 30.days).to_i
          @expiration_field = options.delete(:expiration_field)
          @timestamp_field = options.delete(:timestamp_field)
          @timeout = options.delete(:timeout)
          if options.any?
            raise ArgumentError.new('Could not understand options %s' % options.keys)
          end
        end

        #
        # Check to see if dbs should be rotated. The :window
        # argument specifies how far in advance we should
        # create the new database (default 1.day).
        #
        # This method relies on the assumption that it is called
        # at least once within each @rotation_every period.
        #
        def rotate_database_now(options={})
          window = options[:window] || 1.day

          now = Time.now.utc
          current_name = rotated_database_name(now)
          current_count = now.to_i/@rotation_every

          next_time = window.from_now.utc
          next_name = rotated_database_name(next_time)
          next_count = current_count+1

          prev_name = current_name.sub(/(\d+)$/) {|i| i.to_i-1}
          replication_started = false
          old_name = prev_name.sub(/(\d+)$/) {|i| i.to_i-1} # even older than prev_name
          trailing_edge_time = window.ago.utc

          if !database_exists?(current_name)
            # we should have created the current db earlier, but if somehow
            # it is missing we must make sure it exists.
            create_new_rotated_database(:from => prev_name, :to => current_name)
            replication_started = true
          end

          if next_time.to_i/@rotation_every >= next_count && !database_exists?(next_name)
            # time to create the next db in advance of actually needing it.
            create_new_rotated_database(:from => current_name, :to => next_name)
          end

          if trailing_edge_time.to_i/@rotation_every == current_count
            # delete old dbs, but only after window time has past since the last rotation
            if !replication_started && database_exists?(prev_name)
              # delete previous, but only if we didn't just start replicating from it
              self.server.database(db_name_with_prefix(prev_name)).delete!
            end
            if database_exists?(old_name)
              # there are some edge cases, when rotate_database_now is run
              # infrequently, that an older db might be left around.
              self.server.database(db_name_with_prefix(old_name)).delete!
            end
          end
        end

        def rotated_database_name(time=nil)
          unless @rotation_base_name && @rotation_every
            raise ArgumentError.new('missing @rotation_base_name or @rotation_every')
          end
          time ||= Time.now.utc
          units = time.to_i / @rotation_every.to_i
          "#{@rotation_base_name}_#{units}"
        end

        #
        # create a new empty database.
        #
        def create_database!(name=nil)
          db = if name
            self.server.database!(db_name_with_prefix(name))
          else
            self.database!
          end
          create_rotation_filter(db)
          if self.respond_to?(:design_doc)
            design_doc.sync!(db)
            # or maybe this?:
            #self.design_docs.each do |design|
            #  design.migrate(to_db)
            #end
          end
          return db
        end

        protected

        #
        # Creates database named by options[:to]. Optionally, set up
        # continuous replication from the options[:from] db, if it exists. The
        # assumption is that the from db will be destroyed later, cleaning up
        # the replication once it is no longer needed.
        #
        # This method will also copy design documents if present in the from
        # db, in the CouchRest::Model, or in a database named after
        # @rotation_base_name.
        #
        def create_new_rotated_database(options={})
          from = options[:from]
          to = options[:to]
          to_db = self.create_database!(to)
          if database_exists?(@rotation_base_name)
            base_db = self.server.database(db_name_with_prefix(@rotation_base_name))
            copy_design_docs(base_db, to_db)
          end
          if from && from != to && database_exists?(from)
            from_db = self.server.database(db_name_with_prefix(from))
            replicate_old_to_new(from_db, to_db)
          end
        end

        def copy_design_docs(from, to)
          params = {:startkey => '_design/', :endkey => '_design0', :include_docs => true}
          from.documents(params) do |doc_hash|
            design = doc_hash['doc']
            begin
              to.get(design['_id'])
            rescue CouchRest::NotFound
              design.delete('_rev')
              to.save_doc(design)
            end
          end
        end

        def create_rotation_filter(db)
          name = 'rotation_filter'
          filter_string = if @expiration_field
            NOT_EXPIRED_FILTER % {:expires => @expiration_field}
          elsif @timestamp_field && @timeout
            NOT_TIMED_OUT_FILTER % {:timestamp => @timestamp_field, :timeout => (60 * @timeout)}
          else
            NOT_DELETED_FILTER
          end
          filters = {"not_expired" => filter_string}
          db.save_doc("_id" => "_design/#{name}", "filters" => filters)
        rescue CouchRest::Conflict
        end

        #
        # Replicates documents from_db to to_db, skipping documents that have
        # expired or been deleted.
        #
        # NOTE: It would be better if we could do this:
        #
        #   from_db.replicate_to(to_db, true, false,
        #     :filter => 'rotation_filter/not_expired')
        #
        # But replicate_to() does not support a filter argument, so we call
        # the private method replication() directly.
        #
        def replicate_old_to_new(from_db, to_db)
          create_rotation_filter(from_db)
          from_db.send(:replicate, to_db, true, :source => from_db.name, :filter => 'rotation_filter/not_expired')
        end

        #
        # Three different filters, depending on how the model is set up.
        #
        # NOT_EXPIRED_FILTER is used when there is a single field that
        # contains an absolute time for when the document has expired. The
        #
        # NOT_TIMED_OUT_FILTER is used when there is a field that records the
        # timestamp of the last time the document was used. The expiration in
        # this case is calculated from the timestamp plus @timeout.
        #
        # NOT_DELETED_FILTER is used when the other two cannot be.
        #
        NOT_EXPIRED_FILTER = "" +
%[function(doc, req) {
  if (doc._deleted) {
    return false;
  } else if (typeof(doc.%{expires}) != "undefined") {
    return Date.now() < (new Date(doc.%{expires})).getTime();
  } else {
    return true;
  }
}]

        NOT_TIMED_OUT_FILTER = "" +
%[function(doc, req) {
  if (doc._deleted) {
    return false;
  } else if (typeof(doc.%{timestamp}) != "undefined") {
    return Date.now() < (new Date(doc.%{timestamp})).getTime() + %{timeout};
  } else {
    return true;
  }
}]

        NOT_DELETED_FILTER = "" +
%[function(doc, req) {
  return !doc._deleted;
}]

      end
    end
  end
end
