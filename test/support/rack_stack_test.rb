require 'capybara/rails'
#
# RackStackTest
#
# Tests that will use the entire rack stack from capybara.
#
class RackStackTest < ActionDispatch::IntegrationTest

  CONFIG_RU = (Rails.root + 'config.ru').to_s
  OUTER_APP = Rack::Builder.parse_file(CONFIG_RU).first

  # this is integration testing. So let's make the whole
  # rack stack available...
  Capybara.app = OUTER_APP
  Capybara.run_server = true
  Capybara.app_host = 'http://lvh.me:3003'
  Capybara.server_port = 3003

  # WARNING: this creates an error in the test as soon as there
  # is an error in rails. Use the javascript driver for testing
  # error rendering
  Capybara.register_driver :rack_test do |app|
    Capybara::RackTest::Driver.new(app)
  end

  require 'capybara/poltergeist'

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app)
  end

end
