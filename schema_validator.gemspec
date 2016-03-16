# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schema_validator/version'

Gem::Specification.new do |spec|
  spec.name          = "schema_validator"
  spec.version       = SchemaValidator::VERSION
  spec.authors       = ["mitsuru793"]
  spec.email         = ["mitsuru793@gmail.com"]

  spec.summary       = "validate Array and Hash with simple Array and Hash."
  spec.description   = "You can validate Array and Hash with simple schema of Array and Hash."
  spec.homepage      = "https://github.com/mitsuru793/schema_validator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-test"
  spec.add_development_dependency "terminal-notifier"
  spec.add_development_dependency "terminal-notifier-guard"
end
