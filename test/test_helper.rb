ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'mocha/setup'

# Load support files from all engines
Dir["#{File.dirname(__FILE__)}/../*/test/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  def file_path(name)
    File.join(Rails.root, 'test', 'files', name)
  end

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
Capybara.default_wait_time = 5

class BrowserIntegrationTest < ActionDispatch::IntegrationTest
  # Make the Capybara DSL available
  include Capybara::DSL
  include IntegrationTestHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    page.driver.add_headers 'ACCEPT-LANGUAGE' => 'en-EN'
  end

  teardown do
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

  add_teardown_hook do |testcase|
    unless testcase.passed?
      testcase.save_state
    end
  end

  def save_state
    page.save_screenshot screenshot_path
    File.open(logfile_path, 'w') do |test_log|
      test_log.puts self.class.name
      test_log.puts "========================="
      test_log.puts __name__
      test_log.puts Time.now
      test_log.puts current_path
      test_log.puts page.status_code
      test_log.puts page.response_headers
      test_log.puts "page.html"
      test_log.puts "------------------------"
      test_log.puts page.html
      test_log.puts "server log"
      test_log.puts "------------------------"
      test_log.puts `tail log/test.log -n 200`
    end
  end

  protected

  def logfile_path
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.log"
  end

  def screenshot_path
    Rails.root + 'tmp' + "#{self.class.name.underscore}.#{__name__}.png"
  end
end
