# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/s_expr_nodes'
require_relative '../../lib/skeem/primitive/primitive_builder'

require_relative '../../lib/skeem/runtime' # Load the class under test

module Skeem
  describe Runtime do
    include DatumDSL

    let(:some_env) { SkmFrame.new }

    subject(:runtime) { described_class.new(some_env) }

    context 'Initialization:' do
      it 'is initialized with an environment' do
        expect { described_class.new(SkmFrame.new) }.not_to raise_error
      end

      it 'knows the environment' do
        expect(runtime.environment).to eq(some_env)
      end

      it 'has an empty call stack' do
        expect(runtime.call_stack).to be_empty
      end
    end # context

    context 'Provided services:' do
      it 'adds entries to the environment' do
        entry = double('dummy')
        allow(entry).to receive(:bound!)
        runtime.add_binding('dummy', entry)
        expect(runtime.environment.size).to eq(1)
      end

      it 'knows the keys in the environment' do
        expect(runtime).not_to include('dummy')
        entry = double('dummy')
        allow(entry).to receive(:bound!)
        runtime.add_binding('dummy', entry)
        expect(runtime).to include('dummy')
      end
    end # context

    context 'Evaluation:' do
      include Primitive::PrimitiveBuilder

      # it 'evaluates a given entry' do
        # entry = integer(3)
        # result = double('fake-procedure')
        # expect(entry).to have_received(:expression).and_return(result)
        # expect(result).to have_received(:evaluate).with(runtime).and_return(integer(3))
        # runtime.define('three', entry)
        # expect(runtime.evaluate('three')).to eq(3)
      # end

      it 'evaluates a given list' do
        add_primitives(runtime)
        sum = list([identifier('+'), 3, 4])

        expect(runtime.evaluate_form(sum)).to eq(7)
      end
    end # context

    context 'Environment nesting:' do
      it 'adds nested environment' do
        expect(runtime.depth).to eq(1)
        env_before = runtime.environment
        runtime.nest

        expect(runtime.environment).not_to eq(env_before)
        expect(runtime.environment.parent).to eq(env_before)
        expect(runtime.depth).to eq(2)
      end

      it 'removes nested environment' do
        expect(runtime.depth).to eq(1)
        runtime.nest
        parent_before = runtime.environment.parent
        expect(runtime.depth).to eq(2)

        runtime.unnest
        expect(runtime.environment).to eq(parent_before)
        expect(runtime.depth).to eq(1)
      end
    end # context

    context 'Call stack operations:' do
      let(:sample_call) do
        pos = double('fake-position')
        ProcedureCall.new(pos, identifier('boolean?'), [integer(42)])
      end

      it 'pushes a call to the stack call' do
        expect { runtime.push_call(sample_call) }.not_to raise_error
        expect(runtime.call_stack.size).to eq(1)
        expect(runtime.caller).to eq(sample_call)

        runtime.push_call(sample_call.clone)
        expect(runtime.call_stack.size).to eq(2)
      end

      it 'pops a call from the call stack' do
        runtime.push_call(sample_call)
        expect { runtime.pop_call }.not_to raise_error
        expect(runtime.call_stack).to be_empty

        err = StandardError
        msg = 'Skeem call stack empty!'
        expect { runtime.pop_call }.to raise_error(err, msg)
      end
    end # context
  end # describe
end # module
