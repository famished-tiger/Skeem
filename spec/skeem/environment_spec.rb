require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/environment' # Load the class under test

module Skeem
  describe Environment do
    context 'Initialization:' do
      it 'should be initialized with opional argument' do
        expect { Environment.new() }.not_to raise_error
      end

      it 'should have no default bindings' do
        expect(subject).to be_empty
      end
    end # context

    context 'Provided services:' do
      it 'should add entries' do
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.size).to eq(1)
        expect(subject.bindings['dummy']).not_to be_nil
        expect(subject.bindings['dummy']).to eq(entry)
      end

      it 'should know whether it is empty' do
        # Case 1: no entry
        expect(subject.empty?).to be_truthy

        # Case 2: existing entry
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.empty?).to be_falsey

        # Case 3: entry defined in outer environment
        nested = Environment.new(subject)
        expect(nested.empty?).to be_falsey
      end

      it 'should retrieve entries' do
        # Case 1: non-existing entry
        expect(subject.fetch('dummy')).to be_nil

        # Case 2: existing entry
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.fetch('dummy')).to eq(entry)

        # Case 3: entry defined in outer environment
        nested = Environment.new(subject)
        expect(nested.fetch('dummy')).to eq(entry)
      end

      it 'should know the total number of bindings' do
        # Case 1: non-existing entry
        expect(subject.size).to be_zero

        # Case 2: existing entry
        entry = double('dummy')
        subject.define('dummy', entry)
        expect(subject.size).to eq(1)

        # Case 3: entry defined in outer environment
        nested = Environment.new(subject)
        expect(nested.size).to eq(1)
      end
    end # context

  end # describe
end # module