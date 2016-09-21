# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'druid/version'

Gem::Specification.new do |spec|
  spec.name          = "jruby-druid"
  spec.version       = JrubyDruid::VERSION
  spec.authors       = ["Andre LeBlanc"]
  spec.email         = ["andre.leblanc88@gmail.com"]

  spec.summary       = 'JRuby adapter for Druid.'
  spec.description   = 'JRuby adapter for Druid that allows reads and writes using the Tranquility Kafka API.'
  spec.homepage      = "https://github.com/andremleblanc/jruby-druid"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "jruby-kafka"
  spec.add_dependency "zk"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "faker", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "timecop", "~> 0.8"
  spec.add_development_dependency "webmock", "~> 2.1"
end
