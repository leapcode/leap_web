require 'braintree_test_app'

Braintree::Configuration.logger = Logger.new('log/braintree.log')
Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "bwrdyczvjspmxjhb"
Braintree::Configuration.public_key = "jmw58nbmjg84prbp"
Braintree::Configuration.private_key = "SET_ME"

if Rails.env.test?
  Rails.application.config.middleware.use BraintreeTestApp
end
