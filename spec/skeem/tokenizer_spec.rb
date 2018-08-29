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
        subject.reinitialize("( ) ' `")
        tokens = subject.tokens
        tokens.each { |token| expect(token).to be_kind_of(SToken) }
        terminals = tokens.map(&:terminal)
        prediction = %w[LPAREN RPAREN APOSTROPHE BACKQUOTE]
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

        tests.each do |(input, prediction)|
          subject.reinitialize(input)
          token = subject.tokens.first
          expect(token.terminal).to eq('BOOLEAN')
          expect(token.lexeme).to eq(prediction)
        end
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
          ['-1234', -1234]
        ]

        tests.each do |(input, prediction)|
          subject.reinitialize(input)
          token = subject.tokens.first
          expect(token.terminal).to eq('INTEGER')
          expect(token.lexeme).to eq(prediction)
        end
      end
    end # context

    context 'Real number recognition:' do
      it 'should tokenize real numbers' do
        tests = [
          # couple [raw input, expected]
          ["\t\t3.45e+6", 3.45e+6],
          ['+3.45e+6', +3.45e+6],
          ['-3.45e+6', -3.45e+6]
        ]

        tests.each do |(input, prediction)|
          subject.reinitialize(input)
          token = subject.tokens.first
          expect(token.terminal).to eq('REAL')
          expect(token.lexeme).to eq(prediction)
        end
      end
    end # context

    # TODO
    context 'String recognition:' do
      it 'should tokenize strings' do
        examples = [
          # Some examples taken from R7RS document
          '"Hello world!"',
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
          expect(token.terminal).to eq('IDENTIFIER')
          expect(token.lexeme).to eq(input)
        end
      end
    end # context
=begin
    context 'Scanning Scheme sample code' do
      it 'should read examples from lis.py page' do
        # Shallow tokenizer testing
        source = <<-SCHEME
(if (> (val x) 0)
    (fn (+ (aref A i) (* 3 i))
        (quote (one two)))
      end
    end
SCHEME
        subject.reinitialize(source)
        expect { subject.tokens }.not_to raise_error

        source = "(define circle-area (lambda (r) (* pi (* r r))))"
        subject.reinitialize(source)
        expect { subject.tokens }.not_to raise_error

        source = "(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))"
        subject.reinitialize(source)
        expect { subject.tokens }.not_to raise_error

        source = <<-SCHEME
define first car)
define rest cdr)
define count (lambda (item L) (if L (+ (equal? item (first L)) (count item (rest L))) 0)))
count 0 (list 0 1 2 3 0 0))
SCHEME
        subject.reinitialize(source)
        expect { subject.tokens }.not_to raise_error
      end

      it 'should produce a sequence of token objects' do
        # Deeper tokenizer testing
        source = "(define circle-area (lambda (r) (* pi (* r r))))"
        subject.reinitialize(source)
        predicted = [
          ['LPAREN', '('],
          ['DEFINE', 'define'],
          ['IDENTIFIER', 'circle-area'],
          ['LPAREN', '('],
          ['IDENTIFIER', 'lambda'],
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
=end
  end # describe
end # module
