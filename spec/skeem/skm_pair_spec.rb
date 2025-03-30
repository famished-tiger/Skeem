# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/runtime'
require_relative '../../lib/skeem/skm_pair' # Load the class under test

module Skeem
  describe SkmPair do
    include DatumDSL
    let(:sample_car) { integer(3) }
    let(:sample_cdr) { SkmEmptyList.instance }

    # Default instance is proper list of length 1
    subject(:a_pair) { described_class.new(sample_car, sample_cdr) }

    context 'Initialization:' do
      it 'is initialized with two arguments' do
        expect { described_class.new(sample_car, sample_cdr) }.not_to raise_error
      end

      it "knows its 'car' field" do
        expect(a_pair.car).to eq(sample_car)
      end

      it "knows its 'cdr' field" do
        expect(a_pair.cdr).to eq(sample_cdr)
      end

      # Default (overridable) behavior of SkmElement
      it 'reacts by default to predicates' do
        expect(a_pair).to be_list
        expect(a_pair).not_to be_null
        expect(a_pair).to be_pair
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }
      let(:list_length2) { described_class.new(integer(10), a_pair) }
      let(:quirk_element) { double('three') }
      let(:quirk_members) { [integer(10), quirk_element] }

      it 'clones itself' do
        cloned = a_pair.klone
        expect(cloned.car).to eq(a_pair.car)
        expect(cloned.cdr).to eq(a_pair.cdr)
      end

      it 'clones a proper list' do
        pair2 = described_class.new(identifier('b'), SkmEmptyList.instance)
        pair1 = described_class.new(identifier('a'), pair2)

        cloned = pair1.klone
        expect(cloned.car).to eq(identifier('a'))
        expect(cloned.cdr.car).to eq(identifier('b'))
        expect(cloned.cdr.cdr).to be_null
      end

      it 'clones a improper list' do
        pair2 = described_class.new(identifier('b'), identifier('c'))
        pair1 = described_class.new(identifier('a'), pair2)

        cloned = pair1.klone
        expect(cloned.car).to eq(identifier('a'))
        expect(cloned.cdr.car).to eq(identifier('b'))
        expect(cloned.cdr.cdr).to eq(identifier('c'))
      end

      it 'knows its length' do
        expect(a_pair.length).to eq(1)

        # Use a list of length 2
        expect(list_length2.length).to eq(2)
      end

      it 'responds false to `eqv?` message' do
        expect(a_pair.eqv?(a_pair)).to be(false)
      end

      it 'is Skeem equal to itself' do
        expect(a_pair.skm_equal?(a_pair)).to be(true)
      end


      it 'is equal to other pair when their car and cdr match' do
        instance = described_class.new(sample_car, sample_cdr)
        expect(a_pair.skm_equal?(instance)).to be(true)
        instance.car = integer(4)
        expect(a_pair.skm_equal?(instance)).to be(false)
        instance.car = sample_car
        instance.cdr = a_pair
        expect(a_pair.skm_equal?(instance)).to be(false)
      end

      it 'clones itself after member evaluation' do
        # a_pair contains self-evaluating members
        expect(a_pair.clone_evaluate(runtime)).to eq(a_pair)

        # Make pair improper...
        a_pair.cdr = nil
        expect(a_pair.clone_evaluate(runtime)).to eq(a_pair)

        a_pair.cdr = integer(4)
        expect(a_pair.clone_evaluate(runtime)).to eq(a_pair)

        successor = described_class.new(string('Hi'), boolean(false))
        a_pair.cdr = successor
        expect(a_pair.clone_evaluate(runtime)).to eq(a_pair)
      end

      it 'concerts itself into an array' do
        expect(a_pair.to_a).to eq([sample_car])

        # Use a list of length 2
        expect(list_length2.to_a).to eq([integer(10), sample_car])
      end

      it 'returns the last pair of a proper list' do
        expect(a_pair.last_pair).to eq(a_pair)

        pair2 = described_class.new(identifier('b'), SkmEmptyList.instance)
        pair1 = described_class.new(identifier('a'), pair2)
        expect(pair1.last_pair).to eq(pair1)
      end

      it 'returns the last pair of an improper list' do
        pair3 = described_class.new(identifier('c'), identifier('d'))
        pair2 = described_class.new(identifier('b'), pair3)
        pair1 = described_class.new(identifier('a'), pair2)
        expect(pair1.last_pair).to eq(pair3)
      end

      it 'returns the last element of a list' do
         expect(a_pair.last).to eq(sample_car)
         expect(list_length2.last).to eq(sample_car)
      end

      it 'appends a new element to a list' do
        a_pair.append(integer(4))
        expect(a_pair.length).to eq(2)
        expect(a_pair.to_a).to eq([3, 4])
      end

      it 'creates a list from an array' do
        # List of length 0
        array0 = []
        list = described_class.create_from_a(array0)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(0)
        expect(list.to_a).to eq(array0)

        # List of length 1
        array1 = [boolean(false)]
        list = described_class.create_from_a(array1)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(1)
        expect(list.to_a).to eq(array1)

        # List of length 2
        array2 = [identifier('f'), identifier('g')]
        list = described_class.create_from_a(array2)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(2)
        expect(list.to_a).to eq(array2)

        # List of length 3
        array3 = [integer(4), integer(5), integer(6)]
        list = described_class.create_from_a(array3)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(3)
        expect(list.to_a).to eq([4, 5, 6])
      end

      it 'supports the each method' do
        my_list = described_class.new('w', described_class.new('o', described_class.new('w', SkmEmptyList.instance)))
        text = +''
        my_list.each { |ch| text << ch.upcase }
        expect(text).to eq('WOW')
      end

      it 'implements the verbatim predicate' do
        expect(a_pair).to be_verbatim
        a_pair.cdr = nil
        expect(a_pair).to be_verbatim
        instance = described_class.new(string('Hi'), SkmEmptyList.instance)
        a_pair.cdr = instance
        expect(a_pair).to be_verbatim
        bad_end = double('fake_end')
        instance.cdr = bad_end
        allow(bad_end).to receive(:verbatim?).and_return(false)
        expect(a_pair).not_to be_verbatim
        bad_datum = double('fake-datum')
        allow(bad_datum).to receive(:verbatim?).and_return(false)
        instance.car = bad_datum
        expect(a_pair).not_to be_verbatim
      end

      it 'evaluates its members' do
        # a_pair contains simple literals
        expect(a_pair.evaluate(runtime)).to eq(a_pair)

        # Check that members receive the 'evaluate' message
        allow(quirk_element).to receive(:evaluate).with(runtime).and_return(integer(3))
        instance = described_class.create_from_a(quirk_members)
        expect { instance.evaluate(runtime) }.not_to raise_error
      end

      it 'quasiquote its members' do
        # a_pair contains simple literals
        expect(a_pair.quasiquote(runtime)).to eq(a_pair)

        # Check that members receive the 'quasiquote' message
        allow(quirk_element).to receive(:quasiquote).with(runtime).and_return(integer(3))
        instance = described_class.create_from_a(quirk_members)
        expect { instance.quasiquote(runtime) }.not_to raise_error
      end

      it "replies to visitor's 'accept' message" do
        visitor = double('fake-visitor')
        allow(visitor).to receive(:visit_pair).with(a_pair)
        expect { a_pair.accept(visitor) }.not_to raise_error
      end

      it 'returns its representation upon inspection' do
        predicted = '<Skeem::SkmPair: <Skeem::SkmInteger: 3>>'
        expect(a_pair.inspect).to eq(predicted)

        predicted = '<Skeem::SkmPair: <Skeem::SkmInteger: 10>, <Skeem::SkmInteger: 3>>'
        expect(list_length2.inspect).to eq(predicted)
      end
    end # context
  end # describe
end # module
