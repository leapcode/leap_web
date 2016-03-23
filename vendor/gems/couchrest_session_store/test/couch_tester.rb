#
# Access the couch directly so we can test its state without relying
# on the SessionStore
#

class CouchTester < CouchRest::Document
  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection
  include CouchRest::Model::Rotation

  rotate_database 'sessions',
    :every => 1.month, :expiration_field => :expires

  def initialize(options = {})
  end

  def get(sid)
    database.get(sid)
  end

  def update(sid, diff)
    doc = database.get(sid)
    doc.merge! diff
    database.save_doc(doc)
  end

end
