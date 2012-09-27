# thou shall require all your dependencies in an engine.
require "ruby-srp"
require "leap_web_core"
LeapWebCore::Dependencies.require_ui_gems


module LeapWebUsers
  class Engine < ::Rails::Engine

  end
end
