class CouchRest::Session
end

require 'couchrest/session/utility'
require 'couchrest/session/document'

module CouchRest

  class StorageMissing < Exception
    attr_reader :db
    def initialize(request, db)
      super(request)
      @db = db.name
      @message = "The database '#{db}' does not exist."
    end
  end

  class Session
    include CouchRest::Session::Utility

    def self.fetch(sid)
      self.allocate.tap do |session_doc|
        session_doc.fetch(sid) || raise(CouchRest::NotFound)
      end
    end

    def self.build(sid, session, options = {})
      session_doc = CouchRest::Session::Document.new "_id" => sid
      self.new(session_doc).
        update session, options
    end

    def self.build_or_update(sid, session, options = {})
      options[:marshal_data] = true if options[:marshal_data].nil?
      self.fetch(sid).
        update session, options
    rescue CouchRest::NotFound
      self.build sid, session, options
    end

    def initialize(doc)
      @doc = doc
    end

    def fetch(sid = nil)
      @doc = CouchRest::Session::Document.fetch(sid || doc['_id'])
    end

    def to_session
      if doc["marshalled"]
        session = unmarshal(doc["data"])
      else
        session = doc["data"]
      end
      return session
    end

    def delete
      doc.destroy
    end

    def update(session, options)
      # clean up old data but leave id and revision intact
      doc.reject! { |k,_v| k[0] != '_' }
      doc.merge! data_for_doc(session, options)
      self
    end

    def save
      doc.save
    rescue CouchRest::Conflict
      fetch
      retry
    rescue CouchRest::NotFound => exc
      if exc.http_body =~ /no_db_file/
        exc = CouchRest::StorageMissing.new(exc.response, doc.database)
      end
      raise exc
    end

    def expired?
      expires && expires < Time.now
    end

    protected

    attr_reader :doc

    def data_for_doc(session, options)
      { "data" => options[:marshal_data] ? marshal(session) : session,
        "marshalled" => options[:marshal_data],
        "expires" => expiry_from_options(options) }
    end

    def expiry_from_options(options)
      expire_after = options[:expire_after]
      expire_after && (Time.now + expire_after).utc
    end

    def expires
      doc["expires"] && Time.iso8601(doc["expires"])
    end

  end
end
