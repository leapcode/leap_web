source 'https://rubygems.org'

eval(File.read(File.dirname(__FILE__) + '/common_dependencies.rb'))
eval(File.read(File.dirname(__FILE__) + '/ui_dependencies.rb'))

# EITHER fetch all of the leap_web gems in one go
# gem 'leap_web' 
# OR use the local versions for development instead:
gem "leap_web_core", :path => 'core'
gem 'leap_web_users', :path => 'users'
gem 'leap_web_certs', :path => 'certs'
gem 'leap_web_help', :path => 'help'
# gem 'leap_web_billing', :path => 'billing' # for now, this gem will be included for development and test environments only

# To use debugger
gem 'debugger', :platforms => :mri_19
# ruby 1.8 is not supported anymore
# gem 'ruby-debug', :platforms => :mri_18

group :development do
  gem 'leap_web_billing', :path => 'billing'
end

group :test do
  gem 'fake_braintree', require: false
  gem 'capybara', require: false
  gem 'launchy' # so save_and_open_page works in integration tests
  gem 'leap_web_billing', :path => 'billing'
end

# unreleased so far ... but leap_web_certs need it
gem 'certificate_authority', :git => 'git://github.com/cchandler/certificate_authority.git'
