Rails.configuration.middleware.use RailsWarden::Manager do |config|
  config.default_strategies :secure_remote_password
  config.failure_app = SessionsController
end

RailsWarden.unauthenticated_action = :new

