# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/skm_compound_datum' # Load the classes under test

module Skeem
  describe SkmCompoundDatum do
    include DatumDSL

    let(:sample_members) { [integer(1), integer(2), integer(3)] }

    subject(:datum) { described_class.new(sample_members) }

    context 'Initialization:' do
      it 'is initialized with its members' do
        expect { described_class.new(sample_members) }.not_to raise_error
      end

      it 'knows its members' do
        expect(datum.members).to eq(sample_members)

        other = described_class.new([])
        expect(other.members).to be_empty
      end
    end # context

    context 'Provided basic services:' do
      it 'asserts that it is equal to itself' do
        expect(datum).to eq(datum)
      end

      it 'asserts the equality by member values' do
        # Comparison with other instances
        expect(datum).to eq(described_class.new(sample_members))
        expect(datum).not_to eq(described_class.new([]))
        expect(datum).not_to eq(described_class.new(sample_members.rotate))

        # Comparison with array of values
        expect(datum).to eq(sample_members)
        expect(datum).not_to eq(sample_members.rotate)
      end

      it 'responds to visitor' do
        visitor = double('fake-visitor')
        allow(visitor).to receive(:visit_compound_datum).with(datum)
        expect { datum.accept(visitor) }.not_to raise_error
      end

      it 'returns its text representation' do
        txt1 = '<Skeem::SkmCompoundDatum: <Skeem::SkmInteger: 1>,'
        txt2 = '<Skeem::SkmInteger: 2>, <Skeem::SkmInteger: 3>>'
        expect(datum.inspect).to eq("#{txt1} #{txt2}")
      end
    end # context

    context 'Provided runtime services:' do
      let(:quirk_datum) { double('two') }
      let(:quirk_members) { [integer(1), quirk_datum, integer(3)] }
      let(:runtime) { double('fake-runtime') }

      it 'evaluates its members' do
        # subject contains simple literals
        expect(datum.evaluate(runtime)).to eq(datum)

        # Check that members receive the 'evaluate' message
        allow(quirk_datum).to receive(:evaluate).with(runtime).and_return(integer(2))
        instance = described_class.new(quirk_members)
        expect(instance.evaluate(runtime)).to eq(datum)
      end

      it 'quasiquotes its members' do
        # subject contains simple literals
        expect(datum.quasiquote(runtime)).to eq(datum)

        # Check that members receive the 'quasiquote' message
        allow(quirk_datum).to receive(:quasiquote).with(runtime).and_return(integer(2))
        instance = described_class.new(quirk_members)
        expect(instance.quasiquote(runtime)).to eq(datum)
      end
    end # context
  end # describe

  describe SkmVector do
    let(:sample_members) { [1, 2, 3] }

    subject(:vector) { described_class.new(sample_members) }

    context 'Initialization:' do
      it 'is initialized with its members' do
        expect { described_class.new(sample_members) }.not_to raise_error
      end

      it 'reacts positively to vector? predicate' do
        expect(vector).to be_vector
      end
    end # context
  end # describe
end # module
