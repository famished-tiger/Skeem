# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/skm_frame' # Load the class under test

module Skeem
  describe SkmFrame do
    include DatumDSL

    let(:sample_env) { described_class.new }

    subject(:a_frame) { described_class.new }

    context 'Initialization:' do
      it 'could be initialized without argument' do
        expect { described_class.new }.not_to raise_error
      end

      it 'could be initialized with optional argument' do
        expect { described_class.new(sample_env) }.not_to raise_error
      end

      it 'has no default bindings' do
        expect(a_frame).to be_empty
      end

      it 'has depth of zero or one' do
        expect(a_frame.depth).to be_zero

        instance = described_class.new(sample_env)
        expect(instance.depth).to eq(1)
      end
    end # context

    context 'Provided services:' do
      it 'adds binding' do
        entry = double('original-dummy')
        allow(entry).to receive(:bound!).with(a_frame)

        a_frame.add_binding('dummy', entry)
        expect(a_frame.size).to eq(1)
        expect(a_frame.bindings['dummy']).not_to be_nil
        expect(a_frame.bindings['dummy']).to eq(entry)

        # A child frame may shadow a parent's variable
        child = described_class.new(a_frame)
        entry2 = double('dummy')
        allow(entry2).to receive(:bound!).with(child)
        child.add_binding(identifier('dummy'), entry2)

        expect(child.bindings['dummy']).to eq(entry2)
        expect(a_frame.bindings['dummy']).to eq(entry)
      end

      it 'updates bindings' do
        entry1 = double('dummy')
        allow(entry1).to receive(:bound!).with(a_frame)

        # Case 1: entry defined in this frame
        a_frame.add_binding('dummy', entry1)
        expect(a_frame.bindings['dummy']).to eq(entry1)

        entry2 = double('still-dummy')
        allow(entry2).to receive(:bound!).with(a_frame)
        a_frame.update_binding(identifier('dummy'), entry2)
        expect(a_frame.bindings['dummy']).to eq(entry2)

        # Case 2: entry defined in parent frame
        child = described_class.new(a_frame)
        entry3 = double('still-dummy')
        allow(entry3).to receive(:bound!).with(a_frame)
        child.update_binding('dummy', entry3)
        expect(a_frame.bindings['dummy']).to eq(entry3)
      end

      it 'retrieves entries' do
        # Case 1: non-existing entry
        expect(a_frame.fetch('dummy')).to be_nil

        # Case 2: existing entry
        entry = double('dummy')
        allow(entry).to receive(:bound!).with(a_frame)
        a_frame.add_binding('dummy', entry)
        expect(a_frame.fetch('dummy')).to eq(entry)

        # Case 3: entry defined in parent frame
        child = described_class.new(a_frame)
        expect(child.fetch(identifier('dummy'))).to eq(entry)
      end

      it 'knows whether it is empty' do
        # Case 1: no entry
        expect(a_frame).to be_empty

        # Case 2: existing entry
        entry = double('dummy')
        allow(entry).to receive(:bound!).with(a_frame)
        a_frame.add_binding('dummy', entry)
        expect(a_frame).not_to be_empty

        # Case 3: entry defined in parent frame
        nested = described_class.new(a_frame)
        expect(nested).not_to be_empty
      end

      it 'knows the total number of bindings' do
        # Case 1: non-existing entry
        expect(a_frame.size).to be_zero

        # Case 2: existing entry
        entry = double('dummy')
        allow(entry).to receive(:bound!).with(a_frame)
        a_frame.add_binding('dummy', entry)
        expect(a_frame.size).to eq(1)

        # Case 3: entry defined in parent environment
        nested = described_class.new(a_frame)
        expect(nested.size).to eq(1)
      end
    end # context
  end # describe
end # module
