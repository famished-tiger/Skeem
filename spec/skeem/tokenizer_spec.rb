require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/tokenizer' # Load the class under test

module Skeem
  describe Tokenizer do
    def match_expectations(aTokenizer, theExpectations)
      aTokenizer.tokens.each_with_index do |token, i|
        terminal, lexeme = theExpectations[i]
        expect(token.terminal).to eq(terminal)
        expect(token.lexeme).to eq(lexeme)
      end
    end

    subject { Tokenizer.new('') }

    context 'Initialization:' do
      it 'should be initialized with a text to tokenize' do
        expect { Tokenizer.new('(+ 2 3)') }.not_to raise_error
      end

      it 'should have its scanner initialized' do
        expect(subject.scanner).to be_kind_of(StringScanner)
      end
      
    context 'Delimiter and separator token recognition:' do
      it 'should tokenize single char delimiters' do
        subject.scanner.string = "( ) ' `"
        tokens = subject.tokens
        tokens.each { |token| expect(token).to be_kind_of(SToken) }
        terminals = tokens.map(&:terminal)
        prediction = %w[LPAREN RPAREN APOSTROPHE BACKQUOTE]
        expect(terminals).to eq(prediction)
      end
    end # context
    end # context
  end # describe
end # module
