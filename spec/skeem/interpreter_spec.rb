require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/interpreter' # Load the class under test

module Skeem
  describe Interpreter do
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Interpreter.new() }.not_to raise_error
      end

      it 'should not have its parser initialized' do
        expect(subject.parser).to be_nil
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
          expect(result).to be_kind_of(SExprBooleanNode)
          expect(result.value).to eq(predicted)
        end
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
          expect(result).to be_kind_of(SExprIntegerNode)
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
          expect(result).to be_kind_of(SExprRealNode)
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated strings' do
        samples = [
        ['"Hello, world"', 'Hello, world']
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprStringNode)
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated identifiers' do
        samples = [
        ['the-word-recursion-has-many-meanings', 'the-word-recursion-has-many-meanings']
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SExprIdentifierNode)
          expect(result.value).to eq(predicted)
        end
      end
  end # describe
end # module