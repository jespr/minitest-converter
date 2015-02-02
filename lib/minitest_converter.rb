require "minitest_converter/version"
require "minitest_converter/converters/shoulda"
require "yaml"

module MinitestConverter
  class Converter
    attr_reader :known_word_replacements

    def initialize(path, stdin=STDIN)
      @path = path
      @output = []
      # @known_word_replacements = YAML::load_file = "known_word_replacements.yml"
      @stdin = stdin
    end

    def convert!
      content = File.read(@path)
      replaced = MinitestConverter::Converters::Shoulda.convert!(content)

      File.open(@path, 'w') { |file| file.write(replaced) }
      p "Done!"
    end
  end
end
