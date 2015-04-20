require 'spec_helper'

describe MinitestConverter::Converter do
  def revert(file)
    old = File.read(file)
    yield
  ensure
    File.write(file, old)
  end

  let(:input) { Struct.new(:gets) }

  it 'converts class definitions to describe format' do
    converter = MinitestConverter::Converter.new('spec/files/class_definition.rb')
    expect(converter.convert!).to eq("describe Some::Test do\nend\n")
  end

  it 'converts context blocks to describe format' do
    converter = MinitestConverter::Converter.new('spec/files/context_blocks.rb')
    expect(converter.convert!).to eq("describe \"This is my test\" do\nend\n")
  end

  describe 'converts should blocks to it format' do
    let(:converter) { MinitestConverter::Converter.new('spec/files/should_blocks.rb') }

    it 'returns the right output' do
      expect(converter.convert!).to eq("it \"passes\" do\nend\n")
    end

    it 'adds the word to known words' do
      converter.convert!
      expect(converter.known_word_replacements).to eq({"pass"=>"passes"})
    end
  end

  it 'converts setup blocks to before format' do
    file = 'spec/files/setup_blocks.rb'
    revert file do
      converter = MinitestConverter::Converter.new(file)
      converter.convert!
      expect(File.read(file)).to eq("before do\n  something = 'test'\nend\n\nbefore { something = 'test' }\n")
    end
  end
end
