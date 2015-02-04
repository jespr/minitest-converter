require "minitest_converter/version"
require "minitest_converter/converters/shoulda"

module MinitestConverter
  class Converter
    attr_reader :known_word_replacements

    def initialize(path)
      @path   = path
      @output = []
    end

    def convert!
      files = Dir[File.join(@path, "{**/,}*_{test,spec}.rb")].uniq

      files.each do |file|
        puts file
        convert_and_write_content(file)
      end
    end

    def convert_and_write_content(filename)
      replaced = MinitestConverter::Converters::Shoulda.convert!(File.read(filename))

      File.open(filename, 'w') { |file| file.write(replaced) }
      p "Done!"
    end
  end
end
