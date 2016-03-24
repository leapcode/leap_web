require 'time'

class CouchRest::Session::Document < CouchRest::Document
  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection
  include CouchRest::Model::Rotation

  rotate_database 'sessions',
    :every => 1.month, :expiration_field => :expires

  def self.fetch(id)
    database.get(id)
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

end
