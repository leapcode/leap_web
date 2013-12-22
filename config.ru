# This file is used by Rack-based servers to start the application.

require 'http_accept_language'
use HttpAcceptLanguage::Middleware

require ::File.expand_path('../config/environment',  __FILE__)
run LeapWeb::Application
