require "yaml"

module MinitestConverter
  module Converters
    class Shoulda
      attr_reader :content

      def self.convert!(content)
        new(content, STDIN).convert
      end

      def initialize(content, stdin=STDIN, opts={})
        @content                     = content
        @stdin                       = stdin
        @known_word_replacements     = YAML.load_file("known_word_replacements.yml")
        @ask_for_describe_class_name = opts.fetch(:ask_for_describe_class_name, false)
      end

      def convert
        convert_class_definition
        convert_context_to_describe
        convert_should_to_it
        convert_setup_to_before

        @content
      end

      private

      def update_known_word_replacements
        File.open("known_word_replacements.yml", "w") do |file|
          file.write @known_word_replacements.to_yaml
        end
      end

      def convert_class_definition
        if @content.match(/class (\S+) < ActiveSupport::TestCase/)
          puts 'Converting class definition.....'
          class_name = $1
          class_name_input = ""
          if @ask_for_describe_class_name
            puts "Enter describe class name (#{class_name}):"
            class_name_input = @stdin.gets.to_s.chomp.strip
          end
          class_name_input = class_name.gsub('Test', '') if class_name_input.empty?

          @content = @content.gsub!("class #{class_name} < ActiveSupport::TestCase", "describe '#{class_name_input}' do")
        end
      end

      def convert_context_to_describe
        @content.gsub!('context', 'describe')
        @content
      end

      def convert_setup_to_before
        @content.gsub!(/setup do/, 'before do')
        @content.gsub!(/setup {/, 'before {')
        @content
      end

      def convert_should_to_it
        matches = @content.scan(/^\s+should\s+['"](.*)['"]\s+do$/)

        matches.each do |match|
          existing = match[0]
          first_word = existing.split(' ').first
          unless @known_word_replacements[first_word]
            puts "Rewrite first word (#{existing})"
            substitute = @stdin.gets.to_s.chomp.strip || existing
            @known_word_replacements[first_word] = substitute
            update_known_word_replacements

            unless first_word == substitute
              @content.gsub!(match[0], existing.gsub(first_word, substitute))
            end
          else
            @content.gsub!(match[0], existing.gsub(first_word, @known_word_replacements[first_word]))
          end
        end
        @content.gsub!(/ should /, ' it ')
        @content
      end
    end
  end
end
