# frozen_string_literal: true

require_relative '../../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../../lib/skeem/primitive/primitive_procedure'

module Skeem
  module Primitive
    describe PrimitiveProcedure do
      let(:nullary) { SkmArity.new(0, 0) }
      let(:unary) { SkmArity.new(1, 1) }
      let(:binary) { SkmArity.new(2, 2) }
      let(:zero_or_more) { SkmArity.new(0, '*') }
      let(:one_or_more) { SkmArity.new(1, '*') }
      let(:newline_code) do
        ->(_runtime) { "\n" }
      end

      let(:cube) do
        ->(_runtime, operand) { operand.value * operand.value * operand.value }
      end

      let(:sum) do
        ->(_runtime, operand1, operand2) { operand1.value + operand2.value }
      end

      let(:length) do
        ->(_runtime, operands) { operands.length }
      end

      subject(:primitive) { described_class.new('cube', unary, cube) }

      before { @passing = false }

      context 'Initialization:' do
        it 'is initialized with a name, arity and a lambda' do
          expect { described_class.new('newline', nullary, newline_code) }.not_to raise_error
        end

        it 'knows its name' do
          expect(primitive.identifier.value).to eq('cube')
        end

        it 'knows its arity' do
          expect(primitive.arity).to eq([1, 1])
        end

        it 'knows its lambda' do
          expect(primitive.code).to eq(cube)
        end

        it 'complains if third argument is not a lambda' do
          kode = proc { puts '' }

          err = StandardError
          err_msg = "Primitive procedure 'newline' must be implemented with a Ruby lambda."
          expect { described_class.new('newline', nullary, kode) }.to raise_error(err, err_msg)
        end

        it 'complains if third argument is a nullary lambda' do
          kode = -> { puts '' } # Missing slot for Runtime object

          err = StandardError
          err_msg = "Primitive procedure 'newline' lambda takes no parameter."
          expect { described_class.new('newline', nullary, kode) }.to raise_error(err, err_msg)
        end

        it 'complains when arity and parameter count mismatch' do
          err = StandardError
          msg1 = "Discrepancy in primitive procedure 'cube' "

          msg2 = 'between arity (0) + 1 and parameter count of lambda 2.'
          expect { described_class.new('cube', nullary, cube) }.to raise_error(err, msg1 + msg2)

          msg2 = 'between arity (2) + 1 and parameter count of lambda 2.'
          expect { described_class.new('cube', binary, cube) }.to raise_error(err, msg1 + msg2)

          # Nasty; this discrepancy isn't detected
          expect { described_class.new('cube', zero_or_more, cube) }.not_to raise_error

          expect { described_class.new('cube', unary, cube) }.not_to raise_error

          msg2 = 'between arity (1) + 2 and parameter count of lambda 2.'
          expect { described_class.new('cube', one_or_more, cube) }.to raise_error(err, msg1 + msg2)
        end
      end # context

      context 'Procedure invokation:' do
        it 'supports Skeem nullary procedure' do
          pproc = described_class.new('newline', nullary, newline_code)
          rtime = double('fake-runtime')

          expect(pproc.call(rtime, [])).to eq("\n")

          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure newline>'
          ms2 = ' (required at least 0, got 1)'
          expect { pproc.call(rtime, ['superfluous']) }.to raise_error(err, ms1 + ms2)
        end

        it 'supports Skeem unary procedure' do
          pproc = described_class.new('cube', unary, cube)
          rtime = double('fake-runtime')

          args = [SkmInteger.create(3)]
          expect(pproc.call(rtime, args)).to eq(27)

          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure cube>'
          ms2 = ' (required at least 1, got 0)'
          expect { pproc.call(rtime, []) }.to raise_error(err, ms1 + ms2)

          too_much = %w[foo bar]
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure cube>'
          ms2 = ' (required at least 1, got 2)'
          expect { pproc.call(rtime, too_much) }.to raise_error(err, ms1 + ms2)
        end

        it 'supports Skeem binary procedure' do
          pproc = described_class.new('sum', binary, sum)
          rtime = double('fake-runtime')

          args = [SkmInteger.create(3), SkmInteger.create(5)]
          expect(pproc.call(rtime, args)).to eq(8)

          too_few = [SkmInteger.create(3)]
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure sum>'
          ms2 = ' (required at least 2, got 1)'
          expect { pproc.call(rtime, too_few) }.to raise_error(err, ms1 + ms2)

          too_much = %w[foo bar quux]
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure sum>'
          ms2 = ' (required at least 2, got 3)'
          expect { pproc.call(rtime, too_much) }.to raise_error(err, ms1 + ms2)
        end

        it 'supports Skeem variadic procedure' do
          pproc = described_class.new('length', zero_or_more, length)
          rtime = double('fake-runtime')

          args = [SkmInteger.create(3), SkmInteger.create(5)]
          expect(pproc.call(rtime, args)).to eq(2)

          no_arg = []
          expect(pproc.call(rtime, no_arg)).to eq(0)

          many = [SkmString.create('foo'), SkmString.create('bar'),
            SkmString.create('quux')]
          expect(pproc.call(rtime, many)).to eq(3)
        end
      end # context
    end # describe
  end # module
end # module
