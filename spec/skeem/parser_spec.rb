require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/tokenizer' # Load the class under test

module Skeem
  describe Parser do
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Parser.new() }.not_to raise_error
      end

      it 'should have its parse engine initialized' do
        expect(subject.engine).to be_kind_of(Rley::Engine)
      end
    end # context

    context 'Parsing literals:' do
      it 'should parse isolated booleans' do
        samples = [
        ['#f', false],
        ['#false', false],
        ['#t', true],
        ['#true', true]
      ]
        samples.each do |source, predicted|
          ptree = subject.parse(source)
          expect(ptree.root).to be_kind_of(SExprBoolean)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      it 'should parse isolated integers' do
        samples = [
        ['0', 0],
        ['3', 3],
        ['-3', -3],
        ['+12345', 12345],
        ['-12345', -12345]
      ]
        samples.each do |source, predicted|
          ptree = subject.parse(source)
          expect(ptree.root).to be_kind_of(SExprInteger)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      it 'should parse isolated real numbers' do
        samples = [
        ['0.0', 0.0],
        ['3.14', 3.14],
        ['-3.14', -3.14],
        ['+123e+45', 123e+45],
        ['-123e-45', -123e-45]
      ]
        samples.each do |source, predicted|
          ptree = subject.parse(source)
          expect(ptree.root).to be_kind_of(SExprReal)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      it 'should parse isolated strings' do
        samples = [
        ['"Hello world!"', 'Hello world!']
      ]
        samples.each do |source, predicted|
          ptree = subject.parse(source)
          expect(ptree.root).to be_kind_of(SExprString)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      it 'should parse isolated identifiers' do
        samples = [
        ['the-word-recursion-has-many-meanings', 'the-word-recursion-has-many-meanings']
      ]
        samples.each do |source, predicted|
          ptree = subject.parse(source)
          expect(ptree.root).to be_kind_of(SExprIdentifier)
          expect(ptree.root.value).to eq(predicted)
        end
      end
    end # context

    context 'Parsing forms:' do
      # it 'should parse definitions' do
        # source = '(define r 10)'
        # expect { subject.parse(source) }.not_to raise_error
      # end
    end # context
  end # describe
end # module

# End of file
