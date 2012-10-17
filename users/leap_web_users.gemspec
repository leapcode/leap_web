$:.push File.expand_path("../lib", __FILE__)

require File.expand_path('../../lib/leap_web/version.rb', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leap_web_users"
  s.version     = LeapWeb::VERSION
  s.authors     = ["Azul"]
  s.email       = ["azul@leap.se"]
  s.homepage    = "http://www.leap.se"
  s.summary     = "User registration and authorization for the leap platform"
  s.description = "This this plugin for the leap platform provides user signup and login. It uses Secure Remote Password for the authentication."
  
  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "Readme.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "leap_web_core", LeapWeb::VERSION

  s.add_dependency "ruby-srp", "~> 0.1.3"
end
