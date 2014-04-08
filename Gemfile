source 'https://rubygems.org'

eval(File.read(File.dirname(__FILE__) + '/common_dependencies.rb'))
eval(File.read(File.dirname(__FILE__) + '/ui_dependencies.rb'))

gem "rails", "~> 3.2.11"
gem "couchrest", "~> 1.1.3"
gem "couchrest_model", "~> 2.0.0"
gem "couchrest_session_store", "~> 0.2.4"
gem "json"

gem 'leap_web_users', :path => 'users'
gem 'leap_web_certs', :path => 'certs'
gem 'leap_web_help', :path => 'help'
gem 'leap_web_billing', :path => 'billing'

gem 'http_accept_language'

# To use debugger
gem 'debugger', :platforms => :mri_19
# ruby 1.8 is not supported anymore
# gem 'ruby-debug', :platforms => :mri_18

group :test do
  gem 'fake_braintree', require: false
  gem 'capybara', require: false
  gem 'launchy' # so save_and_open_page works in integration tests
  gem 'phantomjs-binaries'
  gem 'minitest-stub-const'
end

# unreleased so far ... but leap_web_certs need it
gem 'certificate_authority', :git => 'https://github.com/cchandler/certificate_authority.git'
