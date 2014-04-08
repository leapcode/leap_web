# thou shall require all your dependencies in an engine.
require "rails_warden"
require "ruby-srp"

require "warden/session_serializer"
require "warden/strategies/secure_remote_password"

require "webfinger"

module LeapWebUsers
  class Engine < ::Rails::Engine

  end
end
