# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/skm_empty_list' # Load the class under test

module Skeem
  describe SkmEmptyList do
    subject(:empty_list) { described_class.instance }

    context 'Initialization:' do
      it 'is initialized without argument' do
        expect { described_class.instance }.not_to raise_error
      end

      # Default (overridable) behavior of SkmElement
      it 'reacts by default to predicates' do
        expect(empty_list).to be_list
        expect(empty_list).to be_null
        expect(empty_list).not_to be_pair
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { double('fake-runtime') }

      it 'is equivalent to itself' do
        expect(empty_list).to be_eqv(described_class.instance)
        expect(empty_list).not_to be_eqv('()')
      end

      it "returns itself when receiving 'evaluate' message" do
        expect(empty_list.evaluate(runtime)).to eq(empty_list)
      end

      it "returns itself receiving 'quasiquote' message" do
        expect(empty_list.quasiquote(runtime)).to eq(empty_list)
      end

      it "replies to visitor's 'accept' message" do
        visitor = double('fake-visitor')
        allow(visitor).to receive(:visit_empty_list).with(empty_list)
        expect { empty_list.accept(visitor) }.not_to raise_error
      end

      it 'returns its representation upon inspection' do
        predicted = '<Skeem::SkmEmptyList: ()>'
        expect(empty_list.inspect).to eq(predicted)
      end
    end # context
  end # describe
end # module
