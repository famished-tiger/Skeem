require_relative '../spec_helper'


# Load the module under test
require_relative '../../lib/skeem/datum_dsl'

module Skeem
  describe DatumDSL do
    subject do
      obj = Object.new
      obj.extend(DatumDSL) # use the mixin module
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
        [-Rational(2,3), -Rational(2, 3)],
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
        ['hello', 'hello']
      ]
    end

    let(:identifier_tests) do
      [
        ['define', 'define'],
        [SkmString.create('positive?'), 'positive?']
      ]
    end

    let(:simple_datum_tests) do
      [
        ['#t', SkmBoolean.create(true)],
        [-1, SkmInteger.create(-1)],
        [1.41, 1.41],
        ['foo', 'foo']
      ]
    end

    context 'Simple datums:' do
      it 'should convert boolean literals' do
        boolean_tests.each do |(literal, predicted)|
          expect(subject.boolean(literal)).to eq(predicted)
        end
      end

      it 'should convert integer literals' do
        integer_tests.each do |(literal, predicted)|
          expect(subject.integer(literal)).to eq(predicted)
        end
      end
      
      it 'should convert rational literals' do
        rational_tests.each do |(literal, predicted)|
          expect(subject.rational(literal)).to eq(predicted)
        end
      end      

      it 'should convert real number literals' do
        real_tests.each do |(literal, predicted)|
          expect(subject.real(literal)).to eq(predicted)
        end
      end

      it 'should convert string literals' do
        string_tests.each do |(literal, predicted)|
          expect(subject.string(literal)).to eq(predicted)
        end
      end

      it 'should convert identifier literals' do
        identifier_tests.each do |(literal, predicted)|
          expect(subject.identifier(literal)).to eq(predicted)
        end
      end
    end # context


    context 'Compound datums:' do
      it 'should convert empty array into one-member list' do
        result = subject.list([])
        expect(result).to be_kind_of(SkmEmptyList)
        expect(result).to be_null
      end

      it 'should convert array of simple datums into list' do
        literals = simple_datum_tests.map { |(datum, _predicted)| datum }
        predictions = simple_datum_tests.map { |(_datum, predicted)| predicted }
        list_result = subject.list(literals)
        expect(list_result).to be_kind_of(SkmPair)
        list_result.to_a.each_with_index do |member, index|
          expect(member).to eq(predictions[index])
        end
      end

      it 'should convert a single datum into one-member list' do
        result = subject.list('123')
        expect(result).to be_kind_of(SkmPair)
        expect(result.car).to eq(123)
      end

      it 'should convert empty array into one-member list' do
        result = subject.vector([])
        expect(result).to be_kind_of(SkmVector)
        expect(result.members).to be_empty
      end


      it 'should convert array of simple datums into vector' do
        literals = simple_datum_tests.map { |(datum, _predicted)| datum }
        predictions = simple_datum_tests.map { |(_datum, predicted)| predicted }
        vector_result = subject.vector(literals)
        expect(vector_result).to be_kind_of(SkmVector)
        vector_result.members.each_with_index do |member, index|
          expect(member).to eq(predictions[index])
        end
      end

      it 'should convert a single datum into one-member vector' do
        result = subject.vector('123')
        expect(result).to be_kind_of(SkmVector)
        expect(result.members.first).to eq(123)
      end
    end # context

    context 'Arbitrary datums:' do
      it 'should recognize & convert booleans' do
        boolean_tests.each do |(literal, predicted)|
          expect(subject.to_datum(literal)).to eq(predicted)
        end
      end

      it 'should recognize & convert integer literals' do
        integer_tests.each do |(literal, predicted)|
          expect(subject.to_datum(literal)).to eq(predicted)
        end
      end
      
      it 'should recognize & convert rational literals' do
        rational_tests.each do |(literal, predicted)|
          expect(subject.to_datum(literal)).to eq(predicted)
        end
      end      

      it 'should recognize & convert real number literals' do
        real_tests.each do |(literal, predicted)|
          expect(subject.to_datum(literal)).to eq(predicted)
        end
      end

      it 'should recognize & convert string literals' do
        string_tests.each do |(literal, predicted)|
          expect(subject.to_datum(literal)).to eq(predicted)
        end
      end

      it 'should convert nested compound datums' do
        literals = [
          'false', '123', '-1.41',
          'foo', SkmVector.new(['uno', '2', 3.0]), 'bar'
        ]
        result = subject.list(literals)
        expect(result).to be_kind_of(SkmPair)
        expect(result.to_a).to eq([false, 123, -1.41, 'foo', ['uno', 2, 3], 'bar'])
      end
    end

    it 'should duplicate a given list' do
      f = subject.identifier('f')
      g = subject.identifier('g')
      one_list = subject.list([f, g])
      expect(one_list).to be_list
      expect(one_list.to_a).to eq([f, g])
      duplicate = subject.to_datum(one_list)
      expect(duplicate).to be_list
      # $stderr.puts duplicate.inspect
      expect(duplicate.to_a).to eq([f, g])
    end

  end # describe
end # module