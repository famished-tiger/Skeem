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

    # Assumption: subject is a Skeem::Tokenizer
		def check_tokens(tokenTests, tokType)
		  tokenTests.each do |(input, prediction)|
        subject.reinitialize(input)
        token = subject.tokens.first
        expect(token.terminal).to eq(tokType)
        expect(token.lexeme).to eq(prediction)
		  end
		end

    def unquoted(aString)
      aString.gsub(/(^")|("$)/, '')
    end

    # Default instantiation
    subject { Tokenizer.new('') }

    context 'Initialization:' do
      it 'should be initialized with a text to tokenize' do
        expect { Tokenizer.new('(+ 2 3)') }.not_to raise_error
      end

      it 'should have its scanner initialized' do
        expect(subject.scanner).to be_kind_of(StringScanner)
      end
    end # context

    context 'Delimiter and separator token recognition:' do
      it 'should tokenize single char delimiters' do
        subject.reinitialize("( ) ' ` . , ,@")
        tokens = subject.tokens
        tokens.each { |token| expect(token).to be_kind_of(Rley::Lexical::Token) }
        terminals = tokens.map(&:terminal)
        prediction = %w[LPAREN RPAREN APOSTROPHE
          GRAVE_ACCENT PERIOD
          COMMA COMMA_AT_SIGN
        ]
        expect(terminals).to eq(prediction)
      end
    end # context

    context 'Boolean literals recognition:' do
      it 'should tokenize boolean constants' do
        tests = [
          # couple [raw input, expected]
          ['#t', true],
          [' #f', false],
          ['#true ', true],
          [' #false', false]
        ]

        check_tokens(tests, 'BOOLEAN')
      end
    end # context

    context 'Integer literals recognition:' do
      it 'should tokenize integers in default radix 10' do
        tests = [
          # couple [raw input, expected]
          ['0', 0],
          [' 3', 3],
          ['+3 ', +3],
          ['-3', -3],
          ['-3.0', -3],
          ['-1234', -1234]
        ]

        check_tokens(tests, 'INTEGER')
      end
    end # context

    context 'Rational literals recognition:' do
      it 'should tokenize rational in default radix 10' do
        tests = [
          # couple [raw input, expected]
          ['1/2', Rational(1, 2)],
          ['-22/7', -Rational(22, 7)],
        ]

        check_tokens(tests, 'RATIONAL')

        # Special case: implicit promotion to integer
        subject.reinitialize('8/4')
        token = subject.tokens.first
        expect(token.terminal).to eq('INTEGER')
        expect(token.lexeme).to eq(2)
      end
    end # context

    context 'Real number recognition:' do
      it 'should tokenize real numbers' do
        tests = [
          # couple [raw input, expected]
          ["\t\t3.45e+6", 3.45e+6],
          ['+3.45e+6', +3.45e+6],
          ['-3.45e+6', -3.45e+6],
          ['123e+45', 1.23e+47]
        ]

        check_tokens(tests, 'REAL')
      end
    end # context

    context 'Character literal recognition:' do
      it 'should tokenize named characters' do
        tests = [
          # couple [raw input, expected]
          ["#\\alarm", ?\a],
          ["#\\newline", ?\n],
          ["#\\return", ?\r]
        ]

        check_tokens(tests, 'CHAR')
      end

      it 'should tokenize escaped characters' do
        tests = [
          # couple [raw input, expected]
          ["#\\a", ?a],
          ["#\\A", ?A],
          ["#\\(", ?(],
          ["#\\ ", ?\s]
        ]

        check_tokens(tests, 'CHAR')
      end

      it 'should tokenize hex-coded characters' do
        tests = [
          # couple [raw input, expected]
          ["#\\x07", ?\a],
          ["#\\x1B", ?\e],
          ["#\\x3BB", ?\u03bb]
        ]

        check_tokens(tests, 'CHAR')
      end
    end # context

    context 'String recognition:' do
      it 'should tokenize strings' do
        examples = [
          # Some examples taken from R7RS document
          '"Hello, world"',
          '"The word \"recursion\" has many meanings."'
        ]

        examples.each do |input|
          # puts input
          subject.reinitialize(input)
          token = subject.tokens.first
          expect(token.terminal).to eq('STRING_LIT')
          expect(token.lexeme).to eq(unquoted(input))
        end
      end
    end # context
# For later:
# "Another example:\ntwo lines of text"
# "Here's text \
# containing just one line"
# "\x03B1; is named GREEK SMALL LETTER ALPHA."

    context 'Identifier recognition:' do
      it 'should tokenize identifier' do
        examples = [
          # Examples taken from R7RS document
          '...', '+', '+soup+', '<=?',
          '->string', 'a34kTMNs', 'lambda',
          'list->vector', 'q', 'V17a',
          '|two words|', '|two\x20;words|',
          'the-word-recursion-has-many-meanings'
        ]

        examples.each do |input|
          subject.reinitialize(input)
          token = subject.tokens.first
          if token.lexeme == 'lambda'
            expect(token.terminal).to eq('LAMBDA')
          else
            expect(token.terminal).to eq('IDENTIFIER')
          end
          expect(token.lexeme).to eq(input)
        end
      end
    end # context

    context 'Vector recognition' do
      it 'should tokenize vectors' do
        input = '#(0 -2 "Sue")'
        subject.reinitialize(input)
        predictions = [
          ['VECTOR_BEGIN', '#(', 1],
          ['INTEGER', 0, 3],
          ['INTEGER', -2, 5],
          ['STRING_LIT', 'Sue', 8],
          ['RPAREN', ')', 13],
        ]
        tokens = subject.tokens
        predictions.each_with_index do |(pr_terminal, pr_lexeme, pr_position), i|
          expect(tokens[i].terminal).to eq(pr_terminal)
          expect(tokens[i].lexeme).to eq(pr_lexeme)
          expect(tokens[i].position.column).to eq(pr_position)
        end
      end
    end

    context 'Comments:' do
      it 'should skip heading comments' do
        input = "; Starting comment\n \"Some text\""
        subject.reinitialize(input)
        token = subject.tokens.first
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Some text')
        expect(token.position.line).to eq(2)
      end

      it 'should skip trailing comments' do
        input = "\"Some text\"; Trailing comment"
        subject.reinitialize(input)
        token = subject.tokens.first
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Some text')
      end

      it 'should skip embedded comments' do
        input = "\"First text\"; Middle comment\n\"Second text\""
        subject.reinitialize(input)
        tokens = subject.tokens
        expect(tokens.size).to eq(2)
        token = tokens[0]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('First text')
        token = tokens[1]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Second text')
      end

      it 'should skip block comments' do
        input = '"First text" #| Middle comment |# "Second text"'
        subject.reinitialize(input)
        tokens = subject.tokens
        expect(tokens.size).to eq(2)
        token = tokens[0]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('First text')
        token = tokens[1]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Second text')
      end

      it 'should cope with nested block comments' do
        input = '"First text" #| One #| Two |# comment #| Three |# |# "Second text"'
        subject.reinitialize(input)
        tokens = subject.tokens
        expect(tokens.size).to eq(2)
        token = tokens[0]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('First text')
        token = tokens[1]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Second text')
      end
    end

    context 'Scanning Scheme sample code' do
      it 'should produce a sequence of token objects' do
        # Deeper tokenizer testing
        source = "(define circle-area (lambda (r) (* pi (* r r))))"
        subject.reinitialize(source)
        predicted = [
          ['LPAREN', '('],
          ['DEFINE', 'define'],
          ['IDENTIFIER', 'circle-area'],
          ['LPAREN', '('],
          ['LAMBDA', 'lambda'],
          ['LPAREN', '('],
          ['IDENTIFIER', 'r'],
          ['RPAREN', ')'],
          ['LPAREN', '('],
          ['IDENTIFIER', '*'],
          ['IDENTIFIER', 'pi'],
          ['LPAREN', '('],
          ['IDENTIFIER', '*'],
          ['IDENTIFIER', 'r'],
          ['IDENTIFIER', 'r'],
          ['RPAREN', ')'],
          ['RPAREN', ')'],
          ['RPAREN', ')'],
          ['RPAREN', ')']
        ]
        match_expectations(subject, predicted)
      end
    end # context
  end # describe
end # module
