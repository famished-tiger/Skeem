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
    subject { SkmElementVisitor.new(simple_datum) }

    context 'Standard creation & initialization:' do
      it 'should be initialized with a parse tree argument' do
        expect { SkmElementVisitor.new(simple_datum) }.not_to raise_error
      end

      it 'should know the parse tree to visit' do
        expect(subject.root).to eq(simple_datum)
      end

      it "shouldn't have subscribers at start" do
        expect(subject.subscribers).to be_empty
      end
    end # context

    context 'Subscribing:' do
      let(:listener1) { double('fake-subscriber1') }
      let(:listener2) { double('fake-subscriber2') }

      it 'should allow subscriptions' do
        subject.subscribe(listener1)
        expect(subject.subscribers.size).to eq(1)
        expect(subject.subscribers).to eq([listener1])

        subject.subscribe(listener2)
        expect(subject.subscribers.size).to eq(2)
        expect(subject.subscribers).to eq([listener1, listener2])
      end

      it 'should allow un-subcriptions' do
        subject.subscribe(listener1)
        subject.subscribe(listener2)
        subject.unsubscribe(listener2)
        expect(subject.subscribers.size).to eq(1)
        expect(subject.subscribers).to eq([listener1])
        subject.unsubscribe(listener1)
        expect(subject.subscribers).to be_empty
      end
    end # context

    context 'Visiting simple datum:' do
      let(:runtime) { double('fake-runtime') }

      it 'should allow the visit of simple datum object' do
        subject.subscribe(listener)
        expect(listener).to receive(:before_simple_datum).with(runtime, simple_datum)
        expect(listener).to receive(:after_simple_datum).with(runtime, simple_datum)
        subject.start(runtime)
        expect(subject.runtime).to eq(runtime)
      end
    end # context

    context 'Visiting compound datum:' do
      let(:runtime) { double('fake-runtime') }

      it 'should allow the visit of a flat list' do
        ls = list ['#false', 3, 'foo']
        instance = SkmElementVisitor.new(ls)
        instance.subscribe(listener)
        expect(listener).to receive(:before_pair).with(runtime, ls).ordered
        expect(listener).to receive(:before_car).with(runtime, ls, ls.car).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, ls.car).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, ls.car).ordered
        expect(listener).to receive(:after_car).with(runtime, ls, ls.car).ordered
        expect(listener).to receive(:before_cdr).with(runtime, ls, ls.cdr).ordered
        expect(listener).to receive(:before_pair).with(runtime, ls.cdr).ordered
        expect(listener).to receive(:before_car).with(runtime, ls.cdr, ls.cdr.car).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, ls.cdr.car).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, ls.cdr.car).ordered
        expect(listener).to receive(:after_car).with(runtime, ls.cdr, ls.cdr.car).ordered
        expect(listener).to receive(:before_cdr).with(runtime, ls.cdr, ls.cdr.cdr).ordered
        expect(listener).to receive(:before_pair).with(runtime, ls.cdr.cdr).ordered
        expect(listener).to receive(:before_car).with(runtime, ls.cdr.cdr, ls.cdr.cdr.car).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, ls.cdr.cdr.car).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, ls.cdr.cdr.car).ordered
        expect(listener).to receive(:after_car).with(runtime, ls.cdr.cdr, ls.cdr.cdr.car).ordered
        expect(listener).to receive(:before_cdr).with(runtime, ls.cdr.cdr, ls.cdr.cdr.cdr).ordered
        expect(listener).to receive(:before_empty_list).with(runtime, ls.cdr.cdr.cdr).ordered
        expect(listener).to receive(:after_empty_list).with(runtime, ls.cdr.cdr.cdr).ordered
        expect(listener).to receive(:after_cdr).with(runtime, ls.cdr.cdr, ls.cdr.cdr.cdr).ordered
        expect(listener).to receive(:after_pair).with(runtime, ls.cdr.cdr).ordered
        expect(listener).to receive(:after_cdr).with(runtime, ls.cdr, ls.cdr.cdr).ordered
        expect(listener).to receive(:after_pair).with(runtime, ls.cdr).ordered
        expect(listener).to receive(:after_cdr).with(runtime, ls, ls.cdr).ordered
        expect(listener).to receive(:after_pair).with(runtime, ls).ordered
        instance.start(runtime)
      end

      it 'should allow the visit of a flat vector' do
        vec = vector ['#false', 3, 'foo']
        instance = SkmElementVisitor.new(vec)
        instance.subscribe(listener)
        expect(listener).to receive(:before_compound_datum).with(runtime, vec).ordered
        expect(listener).to receive(:before_children).with(runtime, vec, vec.members).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[0]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[0]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[1]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[1]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[2]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[2]).ordered
        expect(listener).to receive(:after_children).with(runtime, vec, vec.members).ordered
        expect(listener).to receive(:after_compound_datum).with(runtime, vec).ordered
        instance.start(runtime)
      end

      it 'should allow the visit of a nested compound datum' do
        nested_list = list %w[uno twei three']
        vec = vector ['#false', 3, nested_list, 'foo']
        instance = SkmElementVisitor.new(vec)
        instance.subscribe(listener)
        expect(listener).to receive(:before_compound_datum).with(runtime, vec).ordered
        expect(listener).to receive(:before_children).with(runtime, vec, vec.members).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[0]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[0]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[1]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[1]).ordered

        expect(listener).to receive(:before_pair).with(runtime, nested_list).ordered
        expect(listener).to receive(:before_car).with(runtime, nested_list, nested_list.car).ordered
        expect(nested_list.car).to eq('uno')
        expect(listener).to receive(:before_simple_datum).with(runtime, nested_list.car).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, nested_list.car).ordered
        expect(listener).to receive(:after_car).with(runtime, nested_list, nested_list.car).ordered
        expect(listener).to receive(:before_cdr).with(runtime, nested_list, nested_list.cdr).ordered
        expect(listener).to receive(:before_pair).with(runtime, nested_list.cdr).ordered
        expect(listener).to receive(:before_car).with(runtime, nested_list.cdr, nested_list.cdr.car).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, nested_list.cdr.car).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, nested_list.cdr.car).ordered
        expect(listener).to receive(:after_car).with(runtime, nested_list.cdr, nested_list.cdr.car).ordered
        expect(listener).to receive(:before_cdr).with(runtime, nested_list.cdr, nested_list.cdr.cdr).ordered
        expect(listener).to receive(:before_pair).with(runtime, nested_list.cdr.cdr).ordered
        expect(listener).to receive(:before_car).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.car).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, nested_list.cdr.cdr.car).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, nested_list.cdr.cdr.car).ordered
        expect(listener).to receive(:after_car).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.car).ordered
        expect(listener).to receive(:before_cdr).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.cdr).ordered
        expect(listener).to receive(:before_empty_list).with(runtime, nested_list.cdr.cdr.cdr).ordered
        expect(listener).to receive(:after_empty_list).with(runtime, nested_list.cdr.cdr.cdr).ordered
        expect(listener).to receive(:after_cdr).with(runtime, nested_list.cdr.cdr, nested_list.cdr.cdr.cdr).ordered
        expect(listener).to receive(:after_pair).with(runtime, nested_list.cdr.cdr).ordered
        expect(listener).to receive(:after_cdr).with(runtime, nested_list.cdr, nested_list.cdr.cdr).ordered
        expect(listener).to receive(:after_pair).with(runtime, nested_list.cdr).ordered
        expect(listener).to receive(:after_cdr).with(runtime, nested_list, nested_list.cdr).ordered
        expect(listener).to receive(:after_pair).with(runtime, nested_list).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[3]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[3]).ordered
        expect(listener).to receive(:after_children).with(runtime, vec, vec.members).ordered
        expect(listener).to receive(:after_compound_datum).with(runtime, vec).ordered
        instance.start(runtime)
      end
    end # context
  end # describe
end # module
