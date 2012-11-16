require "haml"
require "bootstrap-sass"
require "jquery-rails"
require "simple_form"
require "pjax_rails"

if Rails.env == "development"
  require "haml-rails"
  require "sass-rails"
  require "coffee-rails"
  require "uglifier"
end
