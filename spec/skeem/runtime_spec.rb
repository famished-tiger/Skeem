require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/s_expr_nodes'
require_relative '../../lib/skeem/primitive/primitive_builder'

require_relative '../../lib/skeem/runtime' # Load the class under test

module Skeem
  describe Runtime do
    include DatumDSL
    
    let(:some_env) { SkmFrame.new }
    subject { Runtime.new(some_env) }

    context 'Initialization:' do
      it 'should be initialized with an environment' do
        expect { Runtime.new(SkmFrame.new) }.not_to raise_error
      end

      it 'should know the environment' do
        expect(subject.environment).to eq(some_env)
      end
      
      it 'should have an empty call stack' do
        expect(subject.call_stack).to be_empty
      end
    end # context

    context 'Provided services:' do
      it 'should add entries to the environment' do
        entry = double('dummy')
        expect(entry).to receive(:bound!)
        subject.add_binding('dummy', entry)
        expect(subject.environment.size).to eq(1)
      end

      it 'should know the keys in the environment' do
        expect(subject.include?('dummy')).to be_falsey
        entry = double('dummy')
        expect(entry).to receive(:bound!)
        subject.add_binding('dummy', entry)
        expect(subject.include?('dummy')).to be_truthy
      end
    end # context
      
    context 'Evaluation:' do
      include Primitive::PrimitiveBuilder
      
      # it 'should evaluate a given entry' do
        # entry = integer(3)
        # result = double('fake-procedure')
        # expect(entry).to receive(:expression).and_return(result)
        # expect(result).to receive(:evaluate).with(subject).and_return(integer(3))
        # subject.define('three', entry)
        # expect(subject.evaluate('three')).to eq(3)
      # end
      
      it 'should evaluate a given list' do
        add_primitives(subject)
        sum = list([identifier('+'), 3, 4])
        
        expect(subject.evaluate_form(sum)).to eq(7)
      end
    end # context
      
    context 'Environment nesting:' do
      it 'should add nested environment' do
        expect(subject.depth).to eq(1)
        env_before = subject.environment
        subject.nest
        
        expect(subject.environment).not_to eq(env_before)
        expect(subject.environment.parent).to eq(env_before)
        expect(subject.depth).to eq(2)
      end

      it 'should remove nested environment' do
        expect(subject.depth).to eq(1)
        subject.nest
        parent_before = subject.environment.parent
        expect(subject.depth).to eq(2)
        
        subject.unnest
        expect(subject.environment).to eq(parent_before)
        expect(subject.depth).to eq(1)
      end
    end # context
    
    context 'Call stack operations:' do
      let(:sample_call) do
        pos = double('fake-position')
        ProcedureCall.new(pos, identifier('boolean?'), [integer(42)])      
      end
      
      it 'should push a call to the stack call' do
        expect { subject.push_call(sample_call) }.not_to raise_error
        expect(subject.call_stack.size). to eq(1)
        expect(subject.caller).to eq(sample_call)
        
        subject.push_call(sample_call.clone)
        expect(subject.call_stack.size). to eq(2)
      end

      it 'should pop a call from the call stack' do
        subject.push_call(sample_call)
        expect { subject.pop_call }.not_to raise_error
        expect(subject.call_stack).to be_empty
        
        err = StandardError
        msg = 'Skeem call stack empty!'
        expect { subject.pop_call }.to raise_error(err, msg)
      end
    end # context    
  end # describe
end # module