$:.push File.expand_path("../lib", __FILE__)

require File.expand_path('../../lib/leap_web/version.rb', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leap_web_core"
  s.version     = LeapWeb::VERSION
  s.authors     = ["Azul"]
  s.email       = ["azul@leap.se"]
  s.homepage    = "http://www.leap.se"
  s.summary     = "Web interface to the leap platform - core engine"
  s.description = "This web interface provides various administrative tools for the leap platform through plugins. Currently it manages user accounts and certificates."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "Readme.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_dependency "couchrest", "~> 1.1.3"
  s.add_dependency "couchrest_model", "~> 2.0.0.beta2"
  s.add_dependency "couchrest_session_store", "~> 0.0.1"

  s.add_dependency "json"
end
