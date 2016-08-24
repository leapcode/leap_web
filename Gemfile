source 'https://rubygems.org'

require File.expand_path('../lib/gemfile_tools.rb', __FILE__)

## CORE
# rake 11.x throws lots of warnings about rails 3.2 code
gem "rake"
gem "rails", "~> 4.2.7"
# TODO: drop this and the respond_with usage
gem 'responders', '~> 2.0'
gem "couchrest", "~> 2.0.0.rc3"
gem "couchrest_model", "~> 2.1.0.beta2"
if ARGV.grep(/assets:precompile/).empty?
  gem "couchrest_session_store", "~> 0.4.2"
end

## AUTHENTICATION
gem "ruby-srp", "~> 0.2.1"
gem "rails_warden"

## CRYPTO
# we need certificate_authority v2.0, but was never released to rubygems,
# and travis does not work well with github sources, so vendored here:
gem 'certificate_authority', :path => 'vendor/gems/certificate_authority'

## LOCALIZATION
gem 'http_accept_language'
gem 'rails-i18n'  # locale files for built-in validation messages and times
                  # https://github.com/svenfuchs/rails-i18n
                  # for a list of keys:
                  # https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/en.yml
gem 'common_languages', :path => 'vendor/gems/common_languages'

## VIEWS
gem 'kaminari'
gem 'rdiscount'   # for rendering .md templates

## ASSETS
gem "jquery-rails"
gem "simple_form"
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem "haml-rails"
gem "bootstrap-sass"
gem "sass-rails"
group :production do
  gem "uglifier"
  gem 'therubyracer', :platforms => :ruby
  #    ^^ See https://github.com/sstephenson/execjs#readme
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
  gem 'mocha', :require => false
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
  gem 'i18n-missing_translations'
  gem 'pry'
end

group :production do
  gem 'SyslogLogger', '~> 2.0'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :test, :debug do
  # bundler on jessie doesn't support `:platforms => :ruby_21`
  gem 'byebug'
end

##
## OPTIONAL GEMS AND ENGINES
##
gem 'twitter'

enabled_engines.each do |name, gem_info|
  gem gem_info[:name], :path => gem_info[:path], :groups => gem_info[:env]
end

custom_gems.each do |name, gem_info|
  gem gem_info[:name], :path => gem_info[:path]
end

##
## DEPENDENCIES FOR OPTIONAL ENGINES
##

gem 'valid_email' # used by leap_web_help
