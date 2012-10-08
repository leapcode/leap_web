$:.push File.expand_path("../lib", __FILE__)

require "leap_web_core/dependencies"
require File.expand_path('../../lib/leap_web/version.rb', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leap_web_help"
  s.version     = LeapWeb::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of LeapWebHelp."
  s.description = "TODO: Description of LeapWebHelp."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "leap_web_core", "~> #{LeapWeb::VERSION}"
 
  LeapWebCore::Dependencies.add_ui_gems_to_spec(s)
  
  # s.add_dependency "jquery-rails"
end
