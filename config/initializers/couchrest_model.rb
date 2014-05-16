require 'extensions/couchrest'

CouchRest::Model::Base.configure do |config|
  config.auto_update_design_doc = false
end
