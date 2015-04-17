require "yaml"

module MinitestConverter
  module Converters
    class Shoulda
      REPLACEMENTS = File.expand_path("../../replacements.yml", __FILE__)

      attr_reader :content

      def self.convert!(content, options={})
        new(content, STDIN, options).convert
      end

      def initialize(content, stdin=STDIN, options={})
        @content                     = content
        @stdin                       = stdin
        @replacements                = YAML.load_file(REPLACEMENTS)
        @ask_for_describe_class_name = options[:ask_for_describe_class_name]
      end

      def convert
        convert_class_definition
        convert_context_to_describe
        convert_should_to_it
        convert_setup_to_before

        @content
      end

      private

      def store_replacement(a,b)
        @replacements[a] = b
        File.write(REPLACEMENTS, @replacements.to_yaml)
      end

      def convert_class_definition
        return unless class_name = @content[/class (\S+) < ActiveSupport::TestCase/, 1]
        puts 'Converting class definition.....'
        guess = class_name.gsub('Test', '')
        described = guess

        # let user enter the class name manually
        if @ask_for_describe_class_name
          puts "Described class for #{class_name}, Enter for #{guess}:"
          input = @stdin.gets.to_s.chomp.strip
          described = input unless input.empty?
        end

        @content.gsub!("class #{class_name} < ActiveSupport::TestCase", "describe '#{described}' do")
      end

      def convert_context_to_describe
        @content.gsub!(/^(\s+)context /, "\\1describe ")
      end

      def convert_setup_to_before
        @content.gsub!(/setup do/, 'before do')
        @content.gsub!(/setup {/, 'before {')
      end

      def convert_should_to_it
        matches = @content.scan(/^\s+should\s+['"](.*)['"]\s+do$/)

        matches.each do |match|
          existing = match[0]
          first_word = existing.split(' ').first
          unless substitute = @replacements[first_word]
            substitute = case first_word
            when /(ly|s)$/ then first_word
            else
              "#{first_word}s"
            end
          end
          @content.gsub!(match[0], existing.gsub(first_word, substitute))
        end
        @content.gsub!(/^(\s+)should /, "\\1it ")
      end
    end
  end
end
