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
Capybara.javascript_driver = :poltergeist

CONFIG_RU = (Rails.root + 'config.ru').to_s
OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(OUTER_APP)
end

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
class BrowserIntegrationTest < ActionDispatch::IntegrationTest
  # Make the Capybara DSL available
  include Capybara::DSL

  Capybara.app_host = 'http://localhost:3000'
  Capybara.server_port = 3000
  teardown do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end
end
