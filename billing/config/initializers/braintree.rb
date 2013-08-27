require 'braintree_test_app'

Braintree::Configuration.logger = Logger.new('log/braintree.log')

# we use fake braintree in tests
if Rails.env.test?
  Rails.application.config.middleware.use BraintreeTestApp
end

# You can set these per environment in config/config.yml:
if braintree_conf = APP_CONFIG[:braintree]
  Braintree::Configuration.environment = braintree_conf[:environment]
  Braintree::Configuration.merchant_id = braintree_conf[:merchant_id]
  Braintree::Configuration.public_key  = braintree_conf[:public_key]
  Braintree::Configuration.private_key = braintree_conf[:private_key]
end
