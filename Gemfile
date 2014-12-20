source 'https://rubygems.org'

require File.expand_path('../lib/gemfile_tools.rb', __FILE__)

## CORE
gem "rails", "~> 3.2.21"
gem "couchrest", "~> 1.1.3"
gem "couchrest_model", "~> 2.0.0"
gem "couchrest_session_store", "~> 0.2.4"

## AUTHENTICATION
gem "ruby-srp", "~> 0.2.1"
gem "rails_warden"

## LOCALIZATION
gem 'http_accept_language'
gem 'rails-i18n'  # locale files for built-in validation messages and times
                  # https://github.com/svenfuchs/rails-i18n
                  # for a list of keys:
                  # https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/en.yml

## VIEWS
gem 'kaminari', "0.13.0" # for pagination. trying 0.13.0 as there seem to be
                         # issues with 0.14.0 when using couchrest
gem 'rdiscount'   # for rendering .md templates

## ASSETS
gem "jquery-rails"
gem "simple_form"
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
group :assets do
  gem "bootstrap-sass", "= 2.3.2.2" # The last 2.x version. Bootstrap-sass versions
                                    # tracks the version of Bootstrap. We currently require
                                    # Bootstrap v2 because client side validations is incompatible
                                    # with Bootstrap v3. When upgrading to Rails 4, see
                                    # https://github.com/twbs/bootstrap-sass
  gem "haml-rails", "= 0.4.0"   # The last version of haml-rails to support Rails 3.
  gem "sass-rails", "~> 3.2.5"  # Only version supported by bootstrap-sass 2.3.2.2
  gem "uglifier", "~> 1.2.7"    # javascript compression https://github.com/lautis/uglifier
  gem 'quiet_assets'            # stops logging all the asset requests
  gem 'therubyracer', "~> 0.10.2", :platforms => :ruby
  #   ^^ See https://github.com/sstephenson/execjs#readme
  #      for list of supported runtimes.
end

## MISC
gem 'certificate_authority', # unreleased so far ... but leap_web_certs need it
  :git => 'https://github.com/cchandler/certificate_authority.git'

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

group :debug do
  gem 'debugger', :platforms => :mri_19
end

##
## OPTIONAL GEMS AND ENGINES
##

group :test do
  enabled_engines('test').each do |gem_name, gem_dir|
    gem gem_name, :path => gem_dir
  end
end

group :development do
  enabled_engines('development').each do |gem_name, gem_dir|
    gem gem_name, :path => gem_dir
  end
end

group :production do
  enabled_engines('production').each do |gem_name, gem_dir|
    gem gem_name, :path => gem_dir
  end
end

custom_gems.each do |gem_name, gem_dir|
  gem gem_name, :path => gem_dir
end
