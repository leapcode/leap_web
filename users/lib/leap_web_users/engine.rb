# thou shall require all your dependencies in an engine.
require "leap_web_core"
require "leap_web_core/ui_dependencies"
require "rails_warden"
require "ruby-srp"

require "warden/session_serializer"
require "warden/strategies/secure_remote_password"

require "webfinger"
require "whenever"

module LeapWebUsers
  class Engine < ::Rails::Engine

  end
end
