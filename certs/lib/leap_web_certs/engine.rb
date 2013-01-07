require "leap_web_core"
require "leap_ca/config"
LeapCA::Config.db_name = "client_certificates"
require "leap_ca/cert"

module LeapWebCerts
  class Engine < ::Rails::Engine

  end
end
