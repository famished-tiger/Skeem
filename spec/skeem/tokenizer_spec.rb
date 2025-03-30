# frozen_string_literal: true

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
        tokenizer.reset(input)
        token = tokenizer.tokens.first
        expect(token.terminal).to eq(tokType)
        expect(token.lexeme).to eq(prediction)
      end
    end

    def unquoted(aString)
      aString.gsub(/(^")|("$)/, '')
    end

    # Default instantiation
    subject(:tokenizer) { described_class.new('') }

    context 'Initialization:' do
      it 'is initialized with a text to tokenize' do
        expect { described_class.new('(+ 2 3)') }.not_to raise_error
      end

      it 'has its scanner initialized' do
        expect(tokenizer.scanner).to be_a(StringScanner)
      end
    end # context

    context 'Delimiter and separator token recognition:' do
      it 'tokenizes single char delimiters' do
        tokenizer.reset("( ) ' ` . , ,@")
        tokens = tokenizer.tokens
        expect(tokens).to all(be_a(Rley::Lexical::Token))
        terminals = tokens.map(&:terminal)
        prediction = %w[LPAREN RPAREN APOSTROPHE
          GRAVE_ACCENT PERIOD
          COMMA COMMA_AT_SIGN ]
        expect(terminals).to eq(prediction)
      end
    end # context

    context 'Boolean literals recognition:' do
      it 'tokenizes boolean constants' do
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
      it 'tokenizes integers in default radix 10' do
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

      it 'tokenizes integers with explicit radix 10' do
        tests = [
          # couple [raw input, expected]
          ['#d0', 0],
          ['#D3', 3],
          ['#d+3 ', +3],
          ['#D-3', -3],
          ['#d-3.0', -3],
          ['#D-1234', -1234]
        ]

        check_tokens(tests, 'INTEGER')
      end

      it 'tokenizes integers in hexadecimal notation' do
        tests = [
          # couple [raw input, expected]
          ['#x0', 0],
          ['#Xf', 0xf],
          ['#x+F ', 0xf],
          ['#X-f', -0xf],
          ['#X-12Ac', -0x12ac]
        ]

        check_tokens(tests, 'INTEGER')
      end
    end # context

    context 'Rational literals recognition:' do
      it 'tokenizes rational in default radix 10' do
        tests = [
          # couple [raw input, expected]
          ['1/2', Rational(1, 2)],
          ['-22/7', -Rational(22, 7)]
        ]

        check_tokens(tests, 'RATIONAL')

        # Special case: implicit promotion to integer
        tokenizer.reset('8/4')
        token = tokenizer.tokens.first
        expect(token.terminal).to eq('INTEGER')
        expect(token.lexeme).to eq(2)
      end
    end # context

    context 'Real number recognition:' do
      # rubocop: disable Style/ExponentialNotation
      it 'tokenizes real numbers' do
        tests = [
          # couple [raw input, expected]
          ["\t\t3.45e+6", 3.45e+6],
          ['+3.45e+6', +3.45e+6],
          ['-3.45e+6', -3.45e+6],
          ['123e+45', 1.23e+47]
        ]

        check_tokens(tests, 'REAL')
      end
      # rubocop: enable Style/ExponentialNotation
    end # context

    context 'Character literal recognition:' do
      it 'tokenizes named characters' do
        tests = [
          # couple [raw input, expected]
          ['#\alarm', ?\a],
          ['#\newline', ?\n],
          ['#\return', ?\r]
        ]

        check_tokens(tests, 'CHAR')
      end

      it 'tokenizes escaped characters' do
        tests = [
          # couple [raw input, expected]
          ['#\a', ?a],
          ['#\A', ?A],
          ['#\(', ?(],
          ['#\ ', ?\s]
        ]

        check_tokens(tests, 'CHAR')
      end

      it 'tokenizes hex-coded characters' do
        tests = [
          # couple [raw input, expected]
          ['#\x07', ?\a],
          ['#\x1B', ?\e],
          ['#\x3BB', ?\u03bb]
        ]

        check_tokens(tests, 'CHAR')
      end
    end # context

    context 'String recognition:' do
      it 'tokenizes strings' do
        examples = [
          # Some examples taken from R7RS document
          '"Hello, world"',
          '"The word \"recursion\" has many meanings."'
        ]

        examples.each do |input|
          # puts input
          tokenizer.reset(input)
          token = tokenizer.tokens.first
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
      it 'tokenizes identifiers' do
        examples = [
          # Examples taken from R7RS document
          '+', '+soup+', '<=?',
          '->string', 'a34kTMNs', 'lambda',
          'list->vector', 'q', 'V17a',
          '|two words|', '|two\x20;words|',
          'the-word-recursion-has-many-meanings'
        ]

        examples.each do |input|
          tokenizer.reset(input)
          token = tokenizer.tokens.first
          if token.lexeme == 'lambda'
            expect(token.terminal).to eq('LAMBDA')
          else
            expect(token.terminal).to eq('IDENTIFIER')
          end
          expect(token.lexeme).to eq(input)
        end
      end

      it 'recognizes ellipsis' do
        input = '...'
        tokenizer.reset(input)
        token = tokenizer.tokens.first
        expect(token.terminal).to eq('ELLIPSIS')
        expect(token.lexeme).to eq(input)
      end
    end # context

    context 'Vector recognition' do
      it 'tokenizes vectors' do
        input = '#(0 -2 "Sue")'
        tokenizer.reset(input)
        predictions = [
          ['VECTOR_BEGIN', '#(', 1],
          ['INTEGER', 0, 3],
          ['INTEGER', -2, 5],
          ['STRING_LIT', 'Sue', 8],
          ['RPAREN', ')', 13]
        ]
        tokens = tokenizer.tokens
        predictions.each_with_index do |(pr_terminal, pr_lexeme, pr_position), i|
          expect(tokens[i].terminal).to eq(pr_terminal)
          expect(tokens[i].lexeme).to eq(pr_lexeme)
          expect(tokens[i].position.column).to eq(pr_position)
        end
      end
    end

    context 'Comments:' do
      it 'skips heading comments' do
        input = "; Starting comment\n \"Some text\""
        tokenizer.reset(input)
        token = tokenizer.tokens.first
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Some text')
        expect(token.position.line).to eq(2)
      end

      it 'skips trailing comments' do
        input = '"Some text"; Trailing comment'
        tokenizer.reset(input)
        token = tokenizer.tokens.first
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Some text')
      end

      it 'skips embedded comments' do
        input = "\"First text\"; Middle comment\n\"Second text\""
        tokenizer.reset(input)
        tokens = tokenizer.tokens
        expect(tokens.size).to eq(2)
        token = tokens[0]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('First text')
        token = tokens[1]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Second text')
      end

      it 'skips block comments' do
        input = '"First text" #| Middle comment |# "Second text"'
        tokenizer.reset(input)
        tokens = tokenizer.tokens
        expect(tokens.size).to eq(2)
        token = tokens[0]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('First text')
        token = tokens[1]
        expect(token.terminal).to eq('STRING_LIT')
        expect(token.lexeme).to eq('Second text')
      end

      it 'copes with nested block comments' do
        input = '"First text" #| One #| Two |# comment #| Three |# |# "Second text"'
        tokenizer.reset(input)
        tokens = tokenizer.tokens
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
      it 'produces a sequence of token objects' do
        # Deeper tokenizer testing
        source = '(define circle-area (lambda (r) (* pi (* r r))))'
        tokenizer.reset(source)
        predicted = [
          %w[LPAREN (],
          %w[DEFINE define],
          %w[IDENTIFIER circle-area],
          %w[LPAREN (],
          %w[LAMBDA lambda],
          %w[LPAREN (],
          %w[IDENTIFIER r],
          %w[RPAREN )],
          %w[LPAREN (],
          %w[IDENTIFIER *],
          %w[IDENTIFIER pi],
          %w[LPAREN (],
          %w[IDENTIFIER *],
          %w[IDENTIFIER r],
          %w[IDENTIFIER r],
          %w[RPAREN )],
          %w[RPAREN )],
          %w[RPAREN )],
          %w[RPAREN )]
        ]
        match_expectations(tokenizer, predicted)
      end
    end # context
  end # describe
end # module
