require_relative '../spec_helper' # Use the RSpec framework

require_relative '../../lib/skeem/interpreter'
require_relative '../../lib/skeem/skm_procedure_exec' # Load the class under test

module Skeem
  describe SkmProcedureExec do
    let(:interpreter) do
      # We load the interpreter with the primitive procedures only
      Interpreter.new { |interp| interp.add_primitives(interp.runtime) }
    end

    let(:square_source) do
      source = <<-SKEEM
  (define square
    (lambda (x)
      (* x x)))
    square
SKEEM
      source
    end

    let(:sample_lamb) do
      result = interpreter.run(square_source)
      result.last
    end

    let(:sample_call) do
      result = interpreter.parse('(square 3)')
      result.root
    end

    subject { SkmProcedureExec.new(sample_lamb) }

    context 'Initialization:' do
      it 'should be initialized with one lambda' do
        expect { SkmProcedureExec.new(sample_lamb) }.not_to raise_error
      end

      it 'should know the definition of the procedure' do
        expect(subject.definition).to eq(sample_lamb)
      end
    end # context

    context 'Executing a compound procedure:' do
      it 'should execute the procedure that is called' do
        subject
        call_args = sample_call.operands.to_a
        result = subject.run!(interpreter.runtime, call_args)
        expect(result).to eq(9)
      end

      it 'should execute the procedure with a procedure call in argument' do
        subject

        ptree = interpreter.parse('(square (+ (+ 2 1) 2))')
        call_args = ptree.root.operands.to_a
        result = subject.run!(interpreter.runtime, call_args)
        expect(result).to eq(25)
      end
    end
  end # describe
end # module
