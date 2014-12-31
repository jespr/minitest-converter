# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest_converter/version'
name = "minitest-converter"

Gem::Specification.new do |spec|
  spec.name          = name
  spec.version       = Minitest::Converter::VERSION
  spec.authors       = ["Jesper Christiansen"]
  spec.email         = ["hi@jespr.com"]
  spec.description   = "Slobby written shoulda->minitest syntax converter. Better than doing monkey work"
  spec.summary       = ""
  spec.homepage      = "https://github.com/jespr/#{name}"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
end
