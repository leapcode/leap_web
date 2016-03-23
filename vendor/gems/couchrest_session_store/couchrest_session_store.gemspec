# _*_ encoding: utf-8 -*-

Gem::Specification.new do |gem|

  gem.authors = ["Azul"]
  gem.email = ["azul@leap.se"]
  gem.summary = "A Rails Session Store based on CouchRest Model"
  gem.description = gem.summary
  gem.homepage = "http://github.com/azul/couchrest_session_store"

  gem.has_rdoc = true
#  gem.extra_rdoc_files = ["LICENSE"]

  gem.files = `git ls-files`.split("\n")
  gem.name = "couchrest_session_store"
  gem.require_paths = ["lib"]
  gem.version = '0.4.0'

  gem.add_dependency "couchrest"
  gem.add_dependency "couchrest_model"
  gem.add_dependency "actionpack", '~> 4.0'

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "rake"
end
