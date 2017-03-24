require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require gems that depend on a certain load order
# client_side_validations modules get included only if active_model is loaded.
# they will only be included in couchrest_model if that is required last.
require 'active_model'
require 'client_side_validations'
require 'couchrest_model'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

APP_CONFIG = ["defaults.yml", "config.yml"].inject({}) {|config, file|
  filepath = File.expand_path(file, File.dirname(__FILE__))
  if File.exist?(filepath) && settings = YAML.load_file(filepath)[Rails.env]
    config.merge(settings)
  else
    config
  end
}.with_indifferent_access

module LeapWeb
  class Application < Rails::Application

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    if APP_CONFIG[:logfile].present?
      config.logger = Logger.new(APP_CONFIG[:logfile])
    end

    ##
    ## CUSTOMIZATION
    ## see initializers/customization.rb
    ##

    # don't change this (see customization.rb)
    config.assets.initialize_on_precompile = true

    if APP_CONFIG["customization_directory"]
      custom_view_path = (Pathname.new(APP_CONFIG["customization_directory"]).relative_path_from(Rails.root) + 'views').to_s
    else
      custom_view_path = "config/customization/views"
    end
    config.paths['app/views'].unshift custom_view_path


    config.action_dispatch.rescue_responses.merge!(
      'CouchRest::Model::DocumentNotFound' => :not_found,
      'CouchRest::NotFound' => :not_found
    )

    # handle http errors ourselves
    config.exceptions_app = self.routes

  end
end
