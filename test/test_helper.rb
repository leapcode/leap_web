ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mocha/setup'

# Load support files from all engines
Dir["#{File.dirname(__FILE__)}/../*/test/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
end

require 'capybara/poltergeist'

CONFIG_RU = (Rails.root + 'config.ru').to_s
OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
end

# this is integration testing. So let's make the whole
# rack stack available...
Capybara.app = OUTER_APP
Capybara.run_server = true
Capybara.app_host = 'http://lvh.me:3003'
Capybara.server_port = 3003
Capybara.javascript_driver = :poltergeist

class BrowserIntegrationTest < ActionDispatch::IntegrationTest
  # Make the Capybara DSL available
  include Capybara::DSL

  teardown do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end
