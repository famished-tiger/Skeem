require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/primitive/primitive_builder'

require_relative '../../lib/skeem/runtime' # Load the class under test

module Skeem
  describe Runtime do
    include DatumDSL
    
    let(:some_env) { Environment.new }
    subject { Runtime.new(some_env) }

    context 'Initialization:' do
      it 'should be initialized with an environment' do
        expect { Runtime.new(Environment.new) }.not_to raise_error
      end

      it 'should know the environment' do
        expect(subject.environment).to eq(some_env)
      end
    end # context

    context 'Provided services:' do
      it 'should add entries to the environment' do
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.environment.size).to eq(1)
      end

      it 'should know the keys in the environment' do
        expect(subject.include?('dummy')).to be_falsey
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.include?('dummy')).to be_truthy
      end
    end # context
      
    context 'Evaluation:' do
      include Primitive::PrimitiveBuilder
      
      it 'should evaluate a given entry' do
        entry = double('three')
        result = double('fake-procedure')
        expect(entry).to receive(:expression).and_return(result)
        expect(result).to receive(:evaluate).with(subject).and_return(integer(3))
        subject.define('three', entry)
        expect(subject.evaluate('three')).to eq(3)
      end
      
      it 'should evaluate a given list' do
        add_primitives(subject)
        sum = list([identifier('+'), 3, 4])
        
        expect(subject.evaluate_form(sum)).to eq(7)
      end
    end # context
      
    context 'Environment nesting' do
      it 'should add nested environment' do
        expect(subject.depth).to be_zero
        env_before = subject.environment
        subject.nest
        
        expect(subject.environment).not_to eq(env_before)
        expect(subject.environment.outer).to eq(env_before)
        expect(subject.depth).to eq(1)
      end

      it 'should remove nested environment' do
        expect(subject.depth).to be_zero
        subject.nest
        outer_before = subject.environment.outer
        expect(subject.depth).to eq(1)
        
        subject.unnest
        expect(subject.environment).to eq(outer_before)
        expect(subject.depth).to be_zero
      end
    end # context
  end # describe
end # module