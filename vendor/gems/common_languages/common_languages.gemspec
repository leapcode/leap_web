# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'common_languages/version'

Gem::Specification.new do |spec|
  spec.name          = "common_languages"
  spec.version       = CommonLanguages::VERSION
  spec.authors       = ["elijah"]
  spec.email         = ["elijah@leap.se"]
  spec.summary       = %q{Information on the most common languages.}
  spec.description   = %q{Information on the most common languages, including native name and script direction.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['lib/*.rb', 'lib/*/*.rb'] + ['README.md', 'LICENSE.txt']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "i18n"
  spec.add_development_dependency "minitest"
end
