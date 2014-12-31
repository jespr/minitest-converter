require 'spec_helper'

describe MinitestConverter::Converter do
  let(:input) { Struct.new(:gets) }

  it 'converts class definitions to describe format' do
      converter = MinitestConverter::Converter.new('/Users/jchristiansen/projects/minitest-converter/spec/files/class_definition.rb', StringIO.new('Some::Test'))
      expect(converter.convert!).to eq("describe Some::Test do\nend\n")
  end

  it 'converts context blocks to describe format' do
    converter = MinitestConverter::Converter.new('/Users/jchristiansen/projects/minitest-converter/spec/files/context_blocks.rb')
    expect(converter.convert!).to eq("describe \"This is my test\" do\nend\n")
  end

  describe 'converts should blocks to it format' do
    let(:converter) { MinitestConverter::Converter.new('/Users/jchristiansen/projects/minitest-converter/spec/files/should_blocks.rb', StringIO.new('passes')) }

    it 'returns the right output' do
      expect(converter.convert!).to eq("it \"passes\" do\nend\n")
    end

    it 'adds the word to known words' do
      converter.convert!
      expect(converter.known_word_replacements).to eq({"pass"=>"passes"})
    end
  end

  it 'converts setup blocks to before format' do
    converter = MinitestConverter::Converter.new('/Users/jchristiansen/projects/minitest-converter/spec/files/setup_blocks.rb')
    expect(converter.convert!).to eq("before do\n  something = 'test'\nend\n\nbefore { something = 'test' }\n")
  end
end
