$:.push File.expand_path("../../lib", __FILE__)

require File.expand_path('../../../lib/leap_web/version.rb', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leap_web_help"
  s.version     = LeapWeb::VERSION
  s.authors     = ["Jessib"]
  s.email       = ["jessib@leap.se"]
  s.homepage    = "https://www.leap.se"
  s.summary     = "Help Desk for LEAP webapp"
  s.description = "Managing help tickets for a LEAP provider"

  s.files = Dir["{app,config,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

end
