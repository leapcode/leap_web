# thou shall require all your dependencies in an engine.
require "leap_web_core"
#require "leap_web_users" #necessary? 

LeapWebCore::Dependencies.require_ui_gems

module LeapWebHelp
  class Engine < ::Rails::Engine
  end
end
