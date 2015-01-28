# Be sure to restart your server when you modify this file.

unless ARGV.grep(/assets:precompile/)

  LeapWeb::Application.config.session_store CouchRest::Session::Store,
    expire_after: 1800

  CouchRest::Session::Store.configure do |conf|
    conf.environment = Rails.env
    conf.connection_config_file = File.join(Rails.root, 'config', 'couchdb.yml')
    conf.connection[:prefix] =
      Rails.application.class.to_s.underscore.gsub(/\/.*/, '')
  end

end