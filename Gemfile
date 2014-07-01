source 'https://rubygems.org'

require File.expand_path('../lib/gemfile_tools.rb', __FILE__)

gem "rails", "~> 3.2.18"
gem "couchrest", "~> 1.1.3"
gem "couchrest_model", "~> 2.0.0"
gem "couchrest_session_store", "~> 0.2.4"
gem "json"

# user management
gem "ruby-srp", "~> 0.2.1"
gem "rails_warden"

gem 'http_accept_language'

# To use debugger
gem 'debugger', :platforms => :mri_19
# ruby 1.8 is not supported anymore
# gem 'ruby-debug', :platforms => :mri_18

gem "haml", "~> 3.1.7"
gem "bootstrap-sass", "= 2.3.2.2"
gem "jquery-rails"
gem "simple_form"
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem "bootswatch-rails", "~> 0.5.0"

gem 'kaminari', "0.13.0" # for pagination. trying 0.13.0 as there seem to be
                         # issues with 0.14.0 when using couchrest

gem 'rails-i18n'  # locale files for built-in validation messages and times
                  # https://github.com/svenfuchs/rails-i18n
                  # for a list of keys:
                  # https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/en.yml

gem 'rdiscount'   # for rendering .md templates

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
end

group :test, :development do
  gem 'thin'
  gem 'i18n-missing_translations'
end

group :assets do
  gem "haml-rails", "~> 0.3.4"
  gem "sass-rails", "~> 3.2.5"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier", "~> 1.2.7"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', "~> 0.10.2", :platforms => :ruby
  gem 'quiet_assets'       # stops logging all the asset requests
end


group :production do
  gem 'SyslogLogger', '~> 2.0'
end

# unreleased so far ... but leap_web_certs need it
gem 'certificate_authority', :git => 'https://github.com/cchandler/certificate_authority.git'

#
# include optional gems and engines
#

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

