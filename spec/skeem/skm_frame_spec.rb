require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl' 
require_relative '../../lib/skeem/skm_frame' # Load the class under test

module Skeem
  describe SkmFrame do
    include DatumDSL

    let(:sample_env) { SkmFrame.new }
    context 'Initialization:' do
      it 'could be initialized without argument' do
        expect { SkmFrame.new() }.not_to raise_error
      end

      it 'could be initialized with optional argument' do
        expect { SkmFrame.new(sample_env) }.not_to raise_error
      end

      it 'should have no default bindings' do
        expect(subject).to be_empty
      end

      it 'should have depth of zero or one' do
        expect(subject.depth).to be_zero

        instance = SkmFrame.new(sample_env)
        expect(instance.depth).to eq(1)
      end
    end # context

    context 'Provided services:' do
      it 'should add binding' do
        entry = double('original-dummy')
        expect(entry).to receive(:bound!).with(subject)

        subject.add_binding('dummy', entry)
        expect(subject.size).to eq(1)
        expect(subject.bindings['dummy']).not_to be_nil
        expect(subject.bindings['dummy']).to eq(entry)

        # A child frame may shadow a parent's variable
        child = SkmFrame.new(subject)
        entry2 = double('dummy')
        expect(entry2).to receive(:bound!).with(child)
        child.add_binding(identifier('dummy'), entry2)

        expect(child.bindings['dummy']).to eq(entry2)
        expect(subject.bindings['dummy']).to eq(entry)
      end

      it 'should update bindings' do
        entry1 = double('dummy')
        expect(entry1).to receive(:bound!).with(subject)

        # Case 1: entry defined in this frame
        subject.add_binding('dummy', entry1)
        expect(subject.bindings['dummy']).to eq(entry1)

        entry2 = double('still-dummy')
        expect(entry2).to receive(:bound!).with(subject)
        subject.update_binding(identifier('dummy'), entry2)
        expect(subject.bindings['dummy']).to eq(entry2)

        # Case 2: entry defined in parent frame
        child = SkmFrame.new(subject)
        entry3 = double('still-dummy')
        expect(entry3).to receive(:bound!).with(subject)
        child.update_binding('dummy', entry3)
        expect(subject.bindings['dummy']).to eq(entry3)
      end

      it 'should retrieve entries' do
        # Case 1: non-existing entry
        expect(subject.fetch('dummy')).to be_nil

        # Case 2: existing entry
        entry = double('dummy')
        expect(entry).to receive(:bound!).with(subject)
        subject.add_binding('dummy', entry)
        expect(subject.fetch('dummy')).to eq(entry)

        # Case 3: entry defined in parent frame
        child = SkmFrame.new(subject)
        expect(child.fetch(identifier('dummy'))).to eq(entry)
      end

      it 'should know whether it is empty' do
        # Case 1: no entry
        expect(subject.empty?).to be_truthy

        # Case 2: existing entry
        entry = double('dummy')
        expect(entry).to receive(:bound!).with(subject)
        subject.add_binding('dummy', entry)
        expect(subject.empty?).to be_falsey

        # Case 3: entry defined in parent frame
        nested = SkmFrame.new(subject)
        expect(nested.empty?).to be_falsey
      end

      it 'should know the total number of bindings' do
        # Case 1: non-existing entry
        expect(subject.size).to be_zero

        # Case 2: existing entry
        entry = double('dummy')
        expect(entry).to receive(:bound!).with(subject)
        subject.add_binding('dummy', entry)
        expect(subject.size).to eq(1)

        # Case 3: entry defined in parent environment
        nested = SkmFrame.new(subject)
        expect(nested.size).to eq(1)
      end
    end # context

  end # describe
end # module