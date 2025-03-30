# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/tokenizer' # Load the class under test

module Skeem
  describe Parser do
    subject(:parser) { described_class.new }

    context 'Initialization:' do
      it 'is initialized without argument' do
        expect { described_class.new }.not_to raise_error
      end

      it 'has its parse engine initialized' do
        expect(parser.engine).to be_a(Rley::Engine)
      end
    end # context

    context 'Parsing literals:' do
      it 'parses isolated booleans' do
        samples = [
          ['#f', false]
#        ['#false', false],
#        ['#t', true],
#        ['#true', true]
        ]
        samples.each do |source, predicted|
          ptree = parser.parse(source)
          expect(ptree.root).to be_a(SkmBoolean)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      it 'parses isolated integers' do
        samples = [
          ['0', 0],
          ['3', 3],
          ['-3', -3],
          ['+12345', 12345],
          ['-12345', -12345]
        ]
        samples.each do |source, predicted|
          ptree = parser.parse(source)
          expect(ptree.root).to be_a(SkmInteger)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      # rubocop: disable Style/ExponentialNotation
      it 'parses isolated real numbers' do
        samples = [
          ['0.0', 0.0],
          ['3.14', 3.14],
          ['-3.14', -3.14],
          ['+123e+45', 123e+45],
          ['-123e-45', -123e-45]
        ]
        samples.each do |source, predicted|
          ptree = parser.parse(source)
          expect(ptree.root).to be_a(SkmReal)
          expect(ptree.root.value).to eq(predicted)
        end
      end
      # rubocop: enable Style/ExponentialNotation

      it 'parses isolated strings' do
        samples = [
          ['"Hello world!"', 'Hello world!']
        ]
        samples.each do |source, predicted|
          ptree = parser.parse(source)
          expect(ptree.root).to be_a(SkmString)
          expect(ptree.root.value).to eq(predicted)
        end
      end

      it 'parses isolated identifiers' do
        samples = [
          %w[the-word-recursion-has-many-meanings the-word-recursion-has-many-meanings]
        ]
        samples.each do |source, predicted|
          ptree = parser.parse(source)
          expect(ptree.root).to be_a(SkmVariableReference)
          expect(ptree.root.value).to eq(predicted)
        end
      end
    end # context

    # context 'Parsing forms:' do
    #   # it 'parses definitions' do
    #     # source = '(define r 10)'
    #     # expect { parser.parse(source) }.not_to raise_error
    #   # end
    # end # context
  end # describe
end # module

# End of file
