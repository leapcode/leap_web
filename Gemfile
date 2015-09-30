source 'https://rubygems.org'

require File.expand_path('../lib/gemfile_tools.rb', __FILE__)

## CORE
gem "rails", "~> 3.2.21"
gem "couchrest", "~> 1.1.3"
gem "couchrest_model", "~> 2.0.0"
if ARGV.grep(/assets:precompile/).empty?
  gem "couchrest_session_store", "= 0.3.0"
end

## AUTHENTICATION
gem "ruby-srp", "~> 0.2.1"
gem "rails_warden"
gem "coupon_code"

## LOCALIZATION
gem 'http_accept_language'
gem 'rails-i18n'  # locale files for built-in validation messages and times
                  # https://github.com/svenfuchs/rails-i18n
                  # for a list of keys:
                  # https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/en.yml
gem 'common_languages', :path => 'vendor/gems/common_languages'

## VIEWS
gem 'kaminari', "0.13.0" # for pagination. trying 0.13.0 as there seem to be
                         # issues with 0.14.0 when using couchrest
gem 'rdiscount'   # for rendering .md templates

## ASSETS
gem "jquery-rails"
gem "simple_form"
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem "haml-rails", "= 0.4.0"   # The last version of haml-rails to support Rails 3.
gem "bootstrap-sass", "= 2.3.2.2" # The last 2.x version. Bootstrap-sass versions
                                  # tracks the version of Bootstrap. We currently require
                                  # Bootstrap v2 because client side validations is incompatible
                                  # with Bootstrap v3. When upgrading to Rails 4, see
                                  # https://github.com/twbs/bootstrap-sass
gem "sass-rails", "~> 3.2.5"  # Only version supported by bootstrap-sass 2.3.2.2
gem 'quiet_assets'            # stops logging all the asset requests
group :production do
  gem "uglifier", "~> 1.2.7"    # javascript compression https://github.com/lautis/uglifier
                                # this must not be included in development mode, or js
                                # will get included twice.
  gem 'therubyracer', "~> 0.12.2", :platforms => :ruby
  #   ^^ See https://github.com/sstephenson/execjs#readme
  #      for list of supported runtimes.
end

##
## ENVIRONMENT SPECIFIC GEMS
##

group :test do
  # integration testing
  gem 'capybara', require: false
  gem 'poltergeist'         # headless js
  gem 'launchy'             # save_and_open_page
  gem 'phantomjs-binaries'  # binaries specific to the os

  # moching and stubbing
  gem 'mocha', '~> 0.13.0', :require => false
  gem 'minitest-stub-const' # why?

  # generating test data
  gem 'factory_girl_rails'  # test data factories
  gem 'faker'               # names and numbers for test data

  # billing tests
  gem 'fake_braintree', require: false

  # we use cucumber to document and test the api
  gem 'cucumber-rails', require: false
end

group :test, :development do
  gem 'thin'
  gem 'i18n-missing_translations'
end

group :production do
  gem 'SyslogLogger', '~> 2.0'
end

group :development do
  gem "better_errors", '1.1.0'
  gem "binding_of_caller"
end

group :debug do
  gem 'debugger', :platforms => :mri_19
end

##
## OPTIONAL GEMS AND ENGINES
##

enabled_engines.each do |name, gem_info|
  gem gem_info[:name], :path => gem_info[:path], :groups => gem_info[:env]
end

custom_gems.each do |name, gem_info|
  gem gem_info[:name], :path => gem_info[:path]
end

##
## DEPENDENCIES FOR OPTIONAL ENGINES
##

gem 'certificate_authority', # unreleased so far ... but leap_web_certs need it
  :git => 'https://github.com/cchandler/certificate_authority.git'

gem 'valid_email' # used by leap_web_help
