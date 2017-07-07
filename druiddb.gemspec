# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'druid/version'

Gem::Specification.new do |spec|
  spec.name          = "druiddb"
  spec.version       = RubyDruid::VERSION
  spec.authors       = ["Andre LeBlanc"]
  spec.email         = ["andre.leblanc88@gmail.com"]

  spec.summary       = 'Ruby adapter for Druid.'
  spec.description   = 'Ruby adapter for Druid that allows reads and writes using the Tranquility Kafka API.'
  spec.homepage      = "https://github.com/andremleblanc/druiddb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", '~> 5.0'
  spec.add_dependency "ruby-kafka", '~> 0.3'
  spec.add_dependency "zk", '~> 1.9'

  spec.add_development_dependency "bundler", '~> 1.7'
  spec.add_development_dependency "rake", '~> 10.0'
end
