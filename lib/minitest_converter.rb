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
      @known_word_replacements = {}
      @stdin = stdin
    end

    def convert!
      content = File.read(@path)
      replaced = convert_class_definition(content)
      replaced = convert_context_to_describe(replaced)
      replaced = convert_should_to_it(replaced)
      replaced = convert_setup_to_before(replaced)

      replaced
    end

    private

    def convert_class_definition(content)
      if content.match(/class (\S+) < ActiveSupport::TestCase/)
        puts 'Converting class definition.....'
        class_name = $1
        puts "Class name (#{class_name})"
        class_name_input = @stdin.gets.to_s.chomp.strip

        content.gsub!("class #{class_name} < ActiveSupport::TestCase", "describe #{class_name_input} do")
      end
      content
    end

    def convert_context_to_describe(content)
      content.gsub!('context', 'describe')
      content
    end

    def convert_setup_to_before(content)
      content.gsub!(/setup do/, 'before do')
      content.gsub!(/setup {/, 'before {')
      content
    end

    def convert_should_to_it(content)
      matches = content.scan(/should ["'](.+)["'] do/)

      matches.each do |match|
        existing = match[0]
        first_word = existing.split(' ').first
        unless @known_word_replacements.key?(first_word)
          puts "Rewrite first word (#{existing})"
          substitute = @stdin.gets.to_s.chomp.strip || existing
          unless first_word == substitute
            @known_word_replacements[first_word] = substitute
            content.gsub!(match[0], existing.gsub(first_word, substitute))
          end
        else
          content.gsub!(match[0], existing.gsub(first_word, @known_word_replacements[first_word]))
        end
      end
      content.gsub!('should', 'it')
      content
    end
  end
end
