require 'capybara/rails'
# require 'fake_braintree' - messes up other integration tests
require 'braintree_test_app'

class BraintreeIntegrationTest < BrowserIntegrationTest
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
    Rails.application.config.middleware.use BraintreeTestApp
  end

  teardown do
    Warden.test_reset!
    Rails.application.config.middleware.delete "BraintreeTestApp"
  end

end
