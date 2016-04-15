# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'squash_repeater/version'

Gem::Specification.new do |spec|
  spec.name          = "squash_repeater"
  spec.version       = SquashRepeater::VERSION
  spec.authors       = ["Will Robertson"]
  spec.email         = ["will.robertson@powershop.co.nz"]
  spec.summary       = %q{Squash Repeater for Ruby}
  spec.description   = %q{Use beanstalkd to locally queue and repeat Squash exception capturing.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "simplecov", "~> 0.10"
  spec.add_development_dependency "pry-byebug", "~> 3.1"

  spec.add_runtime_dependency "squash_ruby", "~> 2.0"
  spec.add_runtime_dependency "backburner", "1.0"
  spec.add_runtime_dependency "thor", "~> 0.19"
end
