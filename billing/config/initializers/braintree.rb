#
# set logger
#
if APP_CONFIG[:logfile].blank?
  require 'syslog/logger'
  Braintree::Configuration.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new('webapp'))
else
  Braintree::Configuration.logger = Logger.new('log/braintree.log')
end

#
# we use fake braintree in tests
#
if Rails.env.test?
  require 'braintree_test_app'
  Rails.application.config.middleware.use BraintreeTestApp
end

#
# You can set these per environment in config/config.yml:
#
# Environment must be one of: :development, :qa, :sandbox, :production
#
if billing = APP_CONFIG[:billing]
  if braintree = billing[:braintree]
    Braintree::Configuration.environment = braintree[:environment].downcase.to_sym
    Braintree::Configuration.merchant_id = braintree[:merchant_id]
    Braintree::Configuration.public_key  = braintree[:public_key]
    Braintree::Configuration.private_key = braintree[:private_key]
  end
end
