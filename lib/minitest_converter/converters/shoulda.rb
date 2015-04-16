require "yaml"

module MinitestConverter
  module Converters
    class Shoulda
      REPLACEMENTS = File.expand_path("../../replacements.yml", __FILE__)

      attr_reader :content

      def self.convert!(content)
        new(content, STDIN).convert
      end

      def initialize(content, stdin=STDIN, opts={})
        @content                     = content
        @stdin                       = stdin
        @replacements                = YAML.load_file(REPLACEMENTS)
        @ask_for_describe_class_name = opts[:ask_for_describe_class_name]
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
        class_name_input = ""
        if @ask_for_describe_class_name
          puts "Enter describe class name (#{class_name}):"
          class_name_input = @stdin.gets.to_s.chomp.strip
        end
        class_name_input = class_name.gsub('Test', '') if class_name_input.empty?

        @content.gsub!("class #{class_name} < ActiveSupport::TestCase", "describe '#{class_name_input}' do")
      end

      def convert_context_to_describe
        @content.gsub!('context', 'describe')
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
          if substitute = @replacements[first_word]
            @content.gsub!(match[0], existing.gsub(first_word, substitute))
          else
            puts "Rewrite first word (#{existing})"
            substitute = @stdin.gets.to_s.chomp.strip
            store_replacement first_word, substitute

            unless first_word == substitute
              @content.gsub!(match[0], existing.gsub(first_word, substitute))
            end
          end
        end
        @content.gsub!(/ should /, ' it ')
      end
    end
  end
end
