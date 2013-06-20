require "haml"
require "bootstrap-sass"
require "jquery-rails"
require "simple_form"
require "bootswatch-rails"

if Rails.env == "development"
  require "haml-rails"
  require "sass-rails"
  require "coffee-rails"
  require "uglifier"
end
