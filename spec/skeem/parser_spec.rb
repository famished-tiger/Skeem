require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/tokenizer' # Load the class under test

module Skeem
  describe Parser do
  
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Parser.new() }.not_to raise_error
      end

      it 'should have its enginer initialized' do
        expect(subject.engine).to be_kind_of(Rley::Engine)
      end        
    end # context
    
    context 'Parsing:' do
      it 'should parse definitions' do
        source = "(define r 10)"
        expect { subject.parse(source) }.not_to raise_error
      end
    end # context
  end # describe
end # module

# End of file
