require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/environment' # Load the class under test
require_relative '../../lib/skeem/runtime' # Load the class under test

module Skeem
  describe Runtime do
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