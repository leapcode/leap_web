require 'couchrest/session/utility'
require 'time'

class CouchRest::Session::Document < CouchRest::Document
  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection
  include CouchRest::Session::Utility
  include CouchRest::Model::Rotation

  rotate_database 'sessions',
    :every => 1.month, :expiration_field => :expires

  def self.fetch(sid)
    self.allocate.tap do |session_doc|
      session_doc.fetch(sid)
    end
  end

  def self.build(sid, session, options = {})
    self.new(CouchRest::Document.new({"_id" => sid})).tap do |session_doc|
      session_doc.update session, options
    end
  end

  def self.build_or_update(sid, session, options = {})
    options[:marshal_data] = true if options[:marshal_data].nil?
    doc = self.fetch(sid)
    doc.update(session, options)
    return doc
  rescue CouchRest::NotFound
    self.build(sid, session, options)
  end

  def self.find_by_expires(options = {})
    options[:reduce] ||= false
    design = database.get '_design/Session'
    response = design.view :by_expires, options
    response['rows']
  end

  def self.create_database!(name=nil)
    db = super(name)
    begin
      db.get('_design/Session')
    rescue CouchRest::NotFound
      design = File.read(File.expand_path('../../../../design/Session.json', __FILE__))
      design = JSON.parse(design)
      db.save_doc(design.merge({"_id" => "_design/Session"}))
    end
    db
  end

  def initialize(doc)
    @doc = doc
  end

  def fetch(sid = nil)
    @doc = database.get(sid || doc['_id'])
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
    database.delete_doc(doc)
  end

  def update(session, options)
    # clean up old data but leave id and revision intact
    doc.reject! do |k,v|
      k[0] != '_'
    end
    doc.merge! data_for_doc(session, options)
  end

  def save
    database.save_doc(doc)
  rescue CouchRest::Conflict
    fetch
    retry
  rescue CouchRest::NotFound => exc
    if exc.http_body =~ /no_db_file/
      exc = CouchRest::StorageMissing.new(exc.response, database)
    end
    raise exc
  end

  def expired?
    expires && expires < Time.now
  end

  protected

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

  def doc
    @doc
  end

end
