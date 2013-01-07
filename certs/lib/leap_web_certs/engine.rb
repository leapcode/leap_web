require "leap_web_core"
require "leap_ca/config"
LeapCA::Config.db_name = "client_certificates"

# couchrest model has an initializer for this - but apparently that does not work
CouchRest::Model::Base.configure do |conf|
  conf.environment = Rails.env
  conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.yml')
end

require "leap_ca/cert"

module LeapWebCerts
  class Engine < ::Rails::Engine

  end
end
