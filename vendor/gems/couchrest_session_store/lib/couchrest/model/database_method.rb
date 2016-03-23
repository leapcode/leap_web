#
# Allow setting the database to happen dynamically.
#
# Unlike normal CouchRest::Model, the database is not automatically created
# unless you call database!()
#
# The method specified by `database_method` must exist as a class method but
# may optionally also exist as an instance method.
#

module CouchRest
  module Model
    module DatabaseMethod
      extend ActiveSupport::Concern

      def database
        if self.class.database_method
          self.class.server.database(call_database_method)
        else
          self.class.database
        end
      end

      def database!
        if self.class.database_method
          self.class.server.database!(call_database_method)
        else
          self.class.database!
        end
      end

      def database_exists?(db_name)
        self.class.database_exists?(db_name)
      end

      #
      # The normal CouchRest::Model::Base comparison checks if the model's
      # database objects are the same. That is not good for use here, since
      # the objects will always be different. Instead, we compare the string
      # that each database evaluates to.
      #
      def ==(other)
        return false unless other.is_a?(Base)
        if id.nil? && other.id.nil?
          to_hash == other.to_hash
        else
          id == other.id && database.to_s == other.database.to_s
        end
      end
      alias :eql? :==

      protected

      def call_database_method
        if self.respond_to?(self.class.database_method)
          name = self.send(self.class.database_method)
          self.class.db_name_with_prefix(name)
        else
          self.class.send(:call_database_method)
        end
      end

      module ClassMethods

        def database_method(method = nil)
          if method
            @database_method = method
          end
          @database_method
        end
        alias :use_database_method :database_method

        def database
          if database_method
            if !self.respond_to?(database_method)
              raise ArgumentError.new("Incorrect argument to database_method(): no such method '#{method}' found in class #{self}.")
            end
            self.server.database(call_database_method)
          else
            @database ||= prepare_database(super)
          end
        end

        def database!
          if database_method
            self.server.database!(call_database_method)
          else
            @database ||= prepare_database(super)
          end
        end

        #
        # same as database(), but allows for an argument that gets passed through to
        # database method.
        #
        def choose_database(*args)
          self.server.database(call_database_method(*args))
        end

        def db_name_with_prefix(name)
          conf = self.send(:connection_configuration)
          [conf[:prefix], name, conf[:suffix]].reject{|i|i.to_s.empty?}.join(conf[:join])
        end

        def database_exists?(name)
          name = db_name_with_prefix(name)
          begin
            CouchRest.head "#{self.server.uri}/#{name}"
            return true
          rescue CouchRest::NotFound
            return false
          end
        end

        protected

        def call_database_method(*args)
          name = nil
          method = self.method(database_method)
          if method.arity == 0
            name = method.call
          else
            name = method.call(*args)
          end
          db_name_with_prefix(name)
        end

      end
    end
  end
end
