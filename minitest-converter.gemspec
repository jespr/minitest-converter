require './lib/minitest_converter/version'
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

  spec.files         = `git ls-files lib bin LICENSE.txt`.split("\x0")
  spec.executables   = ["minitest_converter"]
end
