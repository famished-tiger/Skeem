require_relative '../../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../../lib/skeem/primitive/primitive_procedure'

module Skeem
  module Primitive
    describe PrimitiveProcedure do
      def call_proc(aName, args)
        ProcedureCall.new(nil, aName, args)
      end

      let(:nullary) { SkmArity.new(0, 0) }
      let(:unary) { SkmArity.new(1, 1) }
      let(:binary) { SkmArity.new(2, 2) }
      let(:zero_or_more) {SkmArity.new(0, '*') }
      let(:one_or_more) {SkmArity.new(1, '*') }
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

      subject { PrimitiveProcedure.new('cube', unary, cube) }

      before(:each) { @passing = false }

      context 'Initialization:' do
        it 'should be initialized with a name, arity and a lambda' do
          expect { PrimitiveProcedure.new('newline', nullary, newline_code) }.not_to raise_error
        end

        it 'should know its name' do
          expect(subject.identifier.value).to eq('cube')
        end

        it 'should know its arity' do
          expect(subject.arity).to eq([1, 1])
        end

        it 'should know its lambda' do
          expect(subject.code).to eq(cube)
        end

        it 'should complain if third argument is not a lambda' do
          kode = Proc.new { puts '' }

          err = StandardError
          err_msg = "Primitive procedure 'newline' must be implemented with a Ruby lambda."
          expect { PrimitiveProcedure.new('newline', nullary, kode) }.to raise_error(err, err_msg)
        end

        it 'should complain if third argument is a nullary lambda' do
          kode = ->() { puts '' } # Missing slot for Runtime object

          err = StandardError
          err_msg = "Primitive procedure 'newline' lambda takes no parameter."
          expect { PrimitiveProcedure.new('newline', nullary, kode) }.to raise_error(err, err_msg)
        end

        it 'should complain when arity and parameter count mismatch' do
          err = StandardError
          msg1 = "Discrepancy in primitive procedure 'cube' "

          msg2 = "between arity (0) + 1 and parameter count of lambda 2."
          expect { PrimitiveProcedure.new('cube', nullary, cube) }.to raise_error(err, msg1 + msg2)

          msg2 = "between arity (2) + 1 and parameter count of lambda 2."
          expect { PrimitiveProcedure.new('cube', binary, cube) }.to raise_error(err, msg1 + msg2)

          # Nasty; this discrepancy isn't detected
          expect { PrimitiveProcedure.new('cube', zero_or_more, cube) }.not_to raise_error

          expect { PrimitiveProcedure.new('cube', unary, cube) }.not_to raise_error

          msg2 = "between arity (1) + 2 and parameter count of lambda 2."
          expect { PrimitiveProcedure.new('cube', one_or_more, cube) }.to raise_error(err, msg1 + msg2)
        end
      end # context

      context 'Procedure invokation:' do
        it 'should support Skeem nullary procedure' do
          pproc = PrimitiveProcedure.new('newline', nullary, newline_code)
          rtime = double('fake-runtime')

          invokation = call_proc('newline', nil)
          expect(pproc.call(rtime, invokation)).to eq("\n")

          too_much = call_proc('newline', ['superfluous'])
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure newline>'
          ms2 = ' (required at least 0, got 1)'
          expect { pproc.call(rtime, too_much) }.to raise_error(err, ms1 + ms2)
        end

        it 'should support Skeem unary procedure' do
          pproc = PrimitiveProcedure.new('cube', unary, cube)
          rtime = double('fake-runtime')

          invokation = call_proc('cube', [SkmInteger.create(3)])
          expect(pproc.call(rtime, invokation)).to eq(27)

          too_few = call_proc('cube', nil)
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure cube>'
          ms2 = ' (required at least 1, got 0)'
          expect { pproc.call(rtime, too_few) }.to raise_error(err, ms1 + ms2)

          too_much = call_proc('newline', ['foo', 'bar'])
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure cube>'
          ms2 = ' (required at least 1, got 2)'
          expect { pproc.call(rtime, too_much) }.to raise_error(err, ms1 + ms2)
        end

        it 'should support Skeem binary procedure' do
          pproc = PrimitiveProcedure.new('sum', binary, sum)
          rtime = double('fake-runtime')

          invokation = call_proc('sum', [SkmInteger.create(3), SkmInteger.create(5)])
          expect(pproc.call(rtime, invokation)).to eq(8)

          too_few = call_proc('sum', [SkmInteger.create(3)])
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure sum>'
          ms2 = ' (required at least 2, got 1)'
          expect { pproc.call(rtime, too_few) }.to raise_error(err, ms1 + ms2)

          too_much = call_proc('cube', ['foo', 'bar', 'quux'])
          err = StandardError
          ms1 = 'Wrong number of arguments for #<Procedure sum>'
          ms2 = ' (required at least 2, got 3)'
          expect { pproc.call(rtime, too_much) }.to raise_error(err, ms1 + ms2)
        end

        it 'should support Skeem variadic procedure' do
          pproc = PrimitiveProcedure.new('length', zero_or_more, length)
          rtime = double('fake-runtime')

          invokation = call_proc('length', [SkmInteger.create(3), SkmInteger.create(5)])
          expect(pproc.call(rtime, invokation)).to eq(2)

          no_arg = call_proc('sum', nil)
          expect(pproc.call(rtime, no_arg)).to eq(0)

          many = call_proc('cube', ['foo', 'bar', 'quux'])
          expect( pproc.call(rtime, many)).to eq(3)
        end
      end # context
    end # describe
  end # module
end # module