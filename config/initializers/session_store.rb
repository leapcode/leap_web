# Be sure to restart your server when you modify this file.

LeapWeb::Application.config.session_store CouchRestSessionStore

CouchRestSessionStore.configure do |conf|
  conf.environment = Rails.env
  conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.yml')
  conf.connection[:prefix] =
    Rails.application.class.to_s.underscore.gsub(/\/.*/, '')
end
