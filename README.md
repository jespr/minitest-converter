# Minitest::Converter

Converts Shoulda tests to minitests

## Installation

Add this line to your application's Gemfile:

    gem 'minitest-converter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest-converter

## Usage

`minitest_converter [path-to-file]`

It converts `should` to `it`
`context` to `describe`
`setup` to `before`


## Contributing

1. Fork it ( http://github.com/<my-github-username>/minitest-converter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
