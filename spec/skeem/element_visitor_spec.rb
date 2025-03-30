# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/skeem/datum_dsl'

# Load the class under test
require_relative '../../lib/skeem/element_visitor'

module Skeem
  describe SkmElementVisitor do
    include DatumDSL
    let(:simple_datum) { integer 42 }
    let(:listener) do
      fake = double('fake-subscriber')
      fake.define_singleton_method(:accept_all) do
        # Dummy block
      end
      fake
    end

    # Default instantiation rule
    subject(:visitor) { described_class.new(simple_datum) }

    context 'Standard creation & initialization:' do
      it 'is initialized with a parse tree argument' do
        expect { described_class.new(simple_datum) }.not_to raise_error
      end

      it 'knows the parse tree to visit' do
        expect(visitor.root).to eq(simple_datum)
      end

      it "doesn't have subscribers at start" do
        expect(visitor.subscribers).to be_empty
      end
    end # context

    context 'Subscribing:' do
      let(:listener1) { double('fake-subscriber1') }
      let(:listener2) { double('fake-subscriber2') }

      it 'allows subscriptions' do
        visitor.subscribe(listener1)
        expect(visitor.subscribers.size).to eq(1)
        expect(visitor.subscribers).to eq([listener1])

        visitor.subscribe(listener2)
        expect(visitor.subscribers.size).to eq(2)
        expect(visitor.subscribers).to eq([listener1, listener2])
      end

      it 'allows un-subcriptions' do
        visitor.subscribe(listener1)
        visitor.subscribe(listener2)
        visitor.unsubscribe(listener2)
        expect(visitor.subscribers.size).to eq(1)
        expect(visitor.subscribers).to eq([listener1])
        visitor.unsubscribe(listener1)
        expect(visitor.subscribers).to be_empty
      end
    end # context

    context 'Visiting simple datum:' do
      let(:runtime) { double('fake-runtime') }

      it 'allows the visit of simple datum object' do
        visitor.subscribe(listener)
        allow(listener).to receive(:before_simple_datum).with(runtime, simple_datum)
        allow(listener).to receive(:after_simple_datum).with(runtime, simple_datum)
        visitor.start(runtime)
        expect(visitor.runtime).to eq(runtime)
      end
    end # context

    context 'Visiting compound datum:' do
      let(:runtime) { double('fake-runtime') }

      it 'allows the visit of a flat list' do
        ls = list ['#false', 3, 'foo']
        instance = described_class.new(ls)
        instance.subscribe(listener)
        allow(listener).to receive(:before_pair).with(runtime, ls)
        allow(listener).to receive(:before_car).with(runtime, ls, ls.car)
        allow(listener).to receive(:before_simple_datum).with(runtime, ls.car)
        allow(listener).to receive(:after_simple_datum).with(runtime, ls.car)
        allow(listener).to receive(:after_car).with(runtime, ls, ls.car)
        allow(listener).to receive(:before_cdr).with(runtime, ls, ls.cdr)
        allow(listener).to receive(:before_pair).with(runtime, ls.cdr)
        allow(listener).to receive(:before_car).with(runtime, ls.cdr, ls.cdr.car)
        allow(listener).to receive(:before_simple_datum).with(runtime, ls.cdr.car)
        allow(listener).to receive(:after_simple_datum).with(runtime, ls.cdr.car)
        allow(listener).to receive(:after_car).with(runtime, ls.cdr, ls.cdr.car)
        allow(listener).to receive(:before_cdr).with(runtime, ls.cdr, ls.cdr.cdr)
        allow(listener).to receive(:before_pair).with(runtime, ls.cdr.cdr)
        allow(listener).to receive(:before_car).with(runtime, ls.cdr.cdr, ls.cdr.cdr.car)
        allow(listener).to receive(:before_simple_datum).with(runtime, ls.cdr.cdr.car)
        allow(listener).to receive(:after_simple_datum).with(runtime, ls.cdr.cdr.car)
        allow(listener).to receive(:after_car).with(runtime, ls.cdr.cdr, ls.cdr.cdr.car)
        allow(listener).to receive(:before_cdr).with(runtime, ls.cdr.cdr, ls.cdr.cdr.cdr)
        allow(listener).to receive(:before_empty_list).with(runtime, ls.cdr.cdr.cdr)
        allow(listener).to receive(:after_empty_list).with(runtime, ls.cdr.cdr.cdr)
        allow(listener).to receive(:after_cdr).with(runtime, ls.cdr.cdr, ls.cdr.cdr.cdr)
        allow(listener).to receive(:after_pair).with(runtime, ls.cdr.cdr)
        allow(listener).to receive(:after_cdr).with(runtime, ls.cdr, ls.cdr.cdr)
        allow(listener).to receive(:after_pair).with(runtime, ls.cdr)
        allow(listener).to receive(:after_cdr).with(runtime, ls, ls.cdr)
        allow(listener).to receive(:after_pair).with(runtime, ls)
        instance.start(runtime)
      end

      it 'allows the visit of a flat vector' do
        vec = vector ['#false', 3, 'foo']
        instance = described_class.new(vec)
        instance.subscribe(listener)
        allow(listener).to receive(:before_compound_datum).with(runtime, vec)
        allow(listener).to receive(:before_children).with(runtime, vec, vec.members)
        allow(listener).to receive(:before_simple_datum).with(runtime, vec.members[0])
        allow(listener).to receive(:after_simple_datum).with(runtime, vec.members[0])
        allow(listener).to receive(:before_simple_datum).with(runtime, vec.members[1])
        allow(listener).to receive(:after_simple_datum).with(runtime, vec.members[1])
        allow(listener).to receive(:before_simple_datum).with(runtime, vec.members[2])
        allow(listener).to receive(:after_simple_datum).with(runtime, vec.members[2])
        allow(listener).to receive(:after_children).with(runtime, vec, vec.members)
        allow(listener).to receive(:after_compound_datum).with(runtime, vec)
        instance.start(runtime)
      end

      it 'allows the visit of a nested compound datum' do
        nested_list = list %w[uno twei three']
        vec = vector ['#false', 3, nested_list, 'foo']
        instance = described_class.new(vec)
        instance.subscribe(listener)
        allow(listener).to receive(:before_compound_datum).with(runtime, vec)
        allow(listener).to receive(:before_children).with(runtime, vec, vec.members)
        allow(listener).to receive(:before_simple_datum).with(runtime, vec.members[0])
        allow(listener).to receive(:after_simple_datum).with(runtime, vec.members[0])
        allow(listener).to receive(:before_simple_datum).with(runtime, vec.members[1])
        allow(listener).to receive(:after_simple_datum).with(runtime, vec.members[1])

        allow(listener).to receive(:before_pair).with(runtime, nested_list)
        allow(listener).to receive(:before_car).with(runtime, nested_list, nested_list.car)
        expect(nested_list.car).to eq('uno')
        allow(listener).to receive(:before_simple_datum).with(runtime, nested_list.car)
        allow(listener).to receive(:after_simple_datum).with(runtime, nested_list.car)
        allow(listener).to receive(:after_car).with(runtime, nested_list, nested_list.car)
        allow(listener).to receive(:before_cdr).with(runtime, nested_list, nested_list.cdr)
        allow(listener).to receive(:before_pair).with(runtime, nested_list.cdr)
        allow(listener).to receive(:before_car).with(runtime, nested_list.cdr, nested_list.cdr.car)
        allow(listener).to receive(:before_simple_datum).with(runtime, nested_list.cdr.car)
        allow(listener).to receive(:after_simple_datum).with(runtime, nested_list.cdr.car)
        allow(listener).to receive(:after_car).with(runtime, nested_list.cdr, nested_list.cdr.car)
        allow(listener).to receive(:before_cdr).with(runtime, nested_list.cdr, nested_list.cdr.cdr)
        allow(listener).to receive(:before_pair).with(runtime, nested_list.cdr.cdr)
        allow(listener).to receive(:before_car).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.car)
        allow(listener).to receive(:before_simple_datum).with(runtime, nested_list.cdr.cdr.car)
        allow(listener).to receive(:after_simple_datum).with(runtime, nested_list.cdr.cdr.car)
        allow(listener).to receive(:after_car).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.car)
        allow(listener).to receive(:before_cdr).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.cdr)
        allow(listener).to receive(:before_empty_list).with(runtime, nested_list.cdr.cdr.cdr)
        allow(listener).to receive(:after_empty_list).with(runtime, nested_list.cdr.cdr.cdr)
        allow(listener).to receive(:after_cdr).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.cdr)
        allow(listener).to receive(:after_pair).with(runtime, nested_list.cdr.cdr)
        allow(listener).to receive(:after_cdr).with(runtime, nested_list.cdr, nested_list.cdr.cdr)
        allow(listener).to receive(:after_pair).with(runtime, nested_list.cdr)
        allow(listener).to receive(:after_cdr).with(runtime, nested_list, nested_list.cdr)
        allow(listener).to receive(:after_pair).with(runtime, nested_list)
        allow(listener).to receive(:before_simple_datum).with(runtime, vec.members[3])
        allow(listener).to receive(:after_simple_datum).with(runtime, vec.members[3])
        allow(listener).to receive(:after_children).with(runtime, vec, vec.members)
        allow(listener).to receive(:after_compound_datum).with(runtime, vec)
        instance.start(runtime)
      end
    end # context
  end # describe
end # modulecls
