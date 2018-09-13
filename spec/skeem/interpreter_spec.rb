require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/interpreter' # Load the class under test

module Skeem
  describe Interpreter do
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Interpreter.new() }.not_to raise_error
      end

      it 'should not have a parser' do
        expect(subject.parser).to be_nil
      end

      it 'should have a runtime object' do
        expect(subject.runtime).to be_kind_of(Runtime)
      end

      it 'should come with built-in functions' do
        expect(subject.runtime.environment).not_to be_empty
      end
    end # context

    context 'Interpreting self-evaluating expressions' do
      it 'should evaluate isolated booleans' do
        samples = [
        ['#f', false],
        ['#false', false],
        ['#t', true],
        ['#true', true]
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprBoolean)
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated integers' do
        samples = [
          ['0', 0],
          ['3', 3],
          ['-3', -3],
          ['+12345', 12345],
          ['-12345', -12345]
        ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprInteger)
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated real numbers' do
        samples = [
          ['0.0', 0.0],
          ['3.14', 3.14],
          ['-3.14', -3.14],
          ['+123e+45', 123e+45],
          ['-123e-45', -123e-45]
        ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprReal)
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated strings' do
        samples = [
        ['"Hello, world"', 'Hello, world']
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprString)
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated identifiers' do
        samples = [
          ['the-word-recursion-has-many-meanings',
          'the-word-recursion-has-many-meanings']
        ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprIdentifier)
          expect(result.value).to eq(predicted)
        end
      end
    end # context

    context 'Built-in primitive functions' do
      it 'should support the addition of integers' do
        result = subject.run('(+ 2 2)')
        expect(result).to be_kind_of(SExprInteger)
        expect(result.value).to eq(4)
      end

      it 'should support the addition of real numbers' do
        result = subject.run('(+ 2 2.34)')
        expect(result).to be_kind_of(SExprReal)
        expect(result.value).to eq(4.34)
      end
      
      it 'should support the product of numbers' do
        result = subject.run('(* 2 3 4)')
        expect(result).to be_kind_of(SExprInteger)
        expect(result.value).to eq(24)      
      end 

      it 'should support the division of numbers' do
        result = subject.run('(/ 24 3)')
        expect(result).to be_kind_of(SExprInteger)
        expect(result.value).to eq(8)      
      end      
      
      it 'should support the arithmetic expressions' do      
        result = subject.run('(+ (* 2 100) (* 1 10))')
        expect(result).to be_kind_of(SExprInteger)
        expect(result.value).to eq(210)
      end       
    end # context
  end # describe
end # module