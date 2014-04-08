$:.push File.expand_path("../lib", __FILE__)

require File.expand_path('../../lib/leap_web/version.rb', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leap_web_billing"
  s.version     = LeapWeb::VERSION
  s.authors     = ["Jessib"]
  s.email       = ["jessib@leap.se"]
  s.homepage    = "http://www.leap.se"
  s.summary     = "Billing for LeapWeb"
  s.description = "Billing System for a Leap provider"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "braintree-rails", "~> 0.4.5"
  s.add_dependency "braintree"
  #s.add_dependency "carmen-rails"
end
