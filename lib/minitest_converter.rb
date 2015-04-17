require "minitest_converter/version"
require "minitest_converter/converters/shoulda"

module MinitestConverter
  class Converter
    def initialize(path, options={})
      @options = options
      @path   = path
      @output = []
    end

    def convert!
      files = (File.file?(@path) ? [@path] : Dir[File.join(@path, "{**/,}*_{test,spec}.rb")].uniq)

      files.each do |file|
        puts file
        convert_and_write_content(file)
      end
    end

    private

    def convert_and_write_content(filename)
      replaced = MinitestConverter::Converters::Shoulda.convert!(File.read(filename), @options)
      File.write(filename, replaced)
      puts "Done!"
    end
  end
end
