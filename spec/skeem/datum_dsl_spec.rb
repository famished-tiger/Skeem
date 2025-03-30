# frozen_string_literal: true

require_relative '../spec_helper'


# Load the module under test
require_relative '../../lib/skeem/datum_dsl'

module Skeem
  describe DatumDSL do
    subject(:dsl) do
      obj = Object.new
      obj.extend(described_class) # use the mixin module
      obj
    end

    let(:boolean_tests) do
      [
        [true, true],
        ['true', true],
        ['#t', true],
        ['#true', true],
        [false, false],
        ['false', false],
        ['#f', false],
        ['false', false]
      ]
    end

    let(:integer_tests) do
      [
        [0, 0],
        [-123, -123],
        [+456, 456],
        ['0', 0],
        ['-123', -123],
        ['+456', 456]
      ]
    end

    let(:rational_tests) do
      [
        [-Rational(2, 3), -Rational(2, 3)],
        [Rational(22, 7), Rational(22, 7)],
        ['-2/3', -Rational(2, 3)],
        ['+22/7', Rational(22, 7)]
      ]
    end

    let(:real_tests) do
      [
        [0, 0],
        [-123.4, -123.4],
        [+456.7, 456.7],
        [-1.234e+3, -1234],
        ['0', 0],
        ['-123.4', -123.4],
        ['+456.7', 456.7],
        ['-1.234e+3', -1234]
      ]
    end

    let(:string_tests) do
      [
        %w[hello hello]
      ]
    end

    let(:identifier_tests) do
      [
        %w[define define],
        [SkmString.create('positive?'), 'positive?']
      ]
    end

    let(:simple_datum_tests) do
      [
        ['#t', SkmBoolean.create(true)],
        [-1, SkmInteger.create(-1)],
        [1.41, 1.41],
        %w[foo foo]
      ]
    end

    context 'Simple datums:' do
      it 'concerts boolean literals' do
        boolean_tests.each do |(literal, predicted)|
          expect(dsl.boolean(literal)).to eq(predicted)
        end
      end

      it 'concerts integer literals' do
        integer_tests.each do |(literal, predicted)|
          expect(dsl.integer(literal)).to eq(predicted)
        end
      end

      it 'concerts rational literals' do
        rational_tests.each do |(literal, predicted)|
          expect(dsl.rational(literal)).to eq(predicted)
        end
      end

      it 'concerts real number literals' do
        real_tests.each do |(literal, predicted)|
          expect(dsl.real(literal)).to eq(predicted)
        end
      end

      it 'concerts string literals' do
        string_tests.each do |(literal, predicted)|
          expect(dsl.string(literal)).to eq(predicted)
        end
      end

      it 'concerts identifier literals' do
        identifier_tests.each do |(literal, predicted)|
          expect(dsl.identifier(literal)).to eq(predicted)
        end
      end
    end # context


    context 'Compound datums:' do
      it 'concerts empty array into one-member list' do
        result = dsl.list([])
        expect(result).to be_a(SkmEmptyList)
        expect(result).to be_null
      end

      it 'concerts array of simple datums into list' do
        literals = simple_datum_tests.map { |(datum, _predicted)| datum }
        predictions = simple_datum_tests.map { |(_datum, predicted)| predicted }
        list_result = dsl.list(literals)
        expect(list_result).to be_a(SkmPair)
        list_result.to_a.each_with_index do |member, index|
          expect(member).to eq(predictions[index])
        end
      end

      it 'concerts a single datum into one-member list' do
        result = dsl.list('123')
        expect(result).to be_a(SkmPair)
        expect(result.car).to eq(123)
      end

      it 'concerts empty array into one-member list' do
        result = dsl.vector([])
        expect(result).to be_a(SkmVector)
        expect(result.members).to be_empty
      end


      it 'concerts array of simple datums into vector' do
        literals = simple_datum_tests.map { |(datum, _predicted)| datum }
        predictions = simple_datum_tests.map { |(_datum, predicted)| predicted }
        vector_result = dsl.vector(literals)
        expect(vector_result).to be_a(SkmVector)
        vector_result.members.each_with_index do |member, index|
          expect(member).to eq(predictions[index])
        end
      end

      it 'concerts a single datum into one-member vector' do
        result = dsl.vector('123')
        expect(result).to be_a(SkmVector)
        expect(result.members.first).to eq(123)
      end
    end # context

    context 'Arbitrary datums:' do
      it 'recognizes & convert booleans' do
        boolean_tests.each do |(literal, predicted)|
          expect(dsl.to_datum(literal)).to eq(predicted)
        end
      end

      it 'recognizes & convert integer literals' do
        integer_tests.each do |(literal, predicted)|
          expect(dsl.to_datum(literal)).to eq(predicted)
        end
      end

      it 'recognizes & convert rational literals' do
        rational_tests.each do |(literal, predicted)|
          expect(dsl.to_datum(literal)).to eq(predicted)
        end
      end

      it 'recognizes & convert real number literals' do
        real_tests.each do |(literal, predicted)|
          expect(dsl.to_datum(literal)).to eq(predicted)
        end
      end

      it 'recognizes & convert string literals' do
        string_tests.each do |(literal, predicted)|
          expect(dsl.to_datum(literal)).to eq(predicted)
        end
      end

      it 'concerts nested compound datums' do
        literals = [
          'false', '123', '-1.41',
          'foo', SkmVector.new(['uno', '2', 3.0]), 'bar'
        ]
        result = dsl.list(literals)
        expect(result).to be_a(SkmPair)
        expect(result.to_a).to eq([false, 123, -1.41, 'foo', ['uno', 2, 3], 'bar'])
      end
    end

    it 'duplicates a given list' do
      f = dsl.identifier('f')
      g = dsl.identifier('g')
      one_list = dsl.list([f, g])
      expect(one_list).to be_list
      expect(one_list.to_a).to eq([f, g])
      duplicate = dsl.to_datum(one_list)
      expect(duplicate).to be_list
      # $stderr.puts duplicate.inspect
      expect(duplicate.to_a).to eq([f, g])
    end
  end # describe
end # module
