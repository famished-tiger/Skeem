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
    fake.define_singleton_method(:accept_all) {}
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
        expect(listener).to receive(:before_compound_datum).with(runtime, ls).ordered
        expect(listener).to receive(:before_children).with(runtime, ls, ls.members).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, ls.members[0]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, ls.members[0]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, ls.members[1]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, ls.members[1]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, ls.members[2]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, ls.members[2]).ordered
        expect(listener).to receive(:after_children).with(runtime, ls, ls.members).ordered
        expect(listener).to receive(:after_compound_datum).with(runtime, ls).ordered
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
        nested_list = list ['uno', 'twei', 'three']
        vec = vector ['#false', 3, nested_list, 'foo']
        instance = SkmElementVisitor.new(vec)
        instance.subscribe(listener)
        expect(listener).to receive(:before_compound_datum).with(runtime, vec).ordered
        expect(listener).to receive(:before_children).with(runtime, vec, vec.members).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[0]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[0]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[1]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[1]).ordered
        expect(listener).to receive(:before_compound_datum).with(runtime, vec.members[2]).ordered
        expect(listener).to receive(:before_children).with(runtime, nested_list, nested_list.members).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, nested_list.members[0]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, nested_list.members[0]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, nested_list.members[1]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, nested_list.members[1]).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, nested_list.members[2]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, nested_list.members[2]).ordered
        expect(listener).to receive(:after_children).with(runtime, nested_list, nested_list.members).ordered
        expect(listener).to receive(:after_compound_datum).with(runtime, nested_list).ordered
        expect(listener).to receive(:before_simple_datum).with(runtime, vec.members[3]).ordered
        expect(listener).to receive(:after_simple_datum).with(runtime, vec.members[3]).ordered
        expect(listener).to receive(:after_children).with(runtime, vec, vec.members).ordered
        expect(listener).to receive(:after_compound_datum).with(runtime, vec).ordered
        instance.start(runtime)
      end

      # it 'should allow the visit of list datum object' do
        # subject.subscribe(listener)
        # expect(listener).to receive(:before_compound_datum).with(runtime, simple_datum)
        # expect(listener).to receive(:after_compound_datum).with(runtime, simple_datum)
        # subject.start(runtime)
        # expect(subject.runtime).to eq(runtime)
      # end
    end # context

=begin
      it 'should react to the start_visit_nonterminal message' do
        # Notify subscribers when start the visit of a non-terminal node
        expect(listener1).to receive(:before_non_terminal).with(nterm_node)
        subject.visit_nonterminal(nterm_node)
      end

      it 'should react to the visit_children message' do
        # Notify subscribers when start the visit of children nodes
        children = nterm_node.subnodes
        args = [nterm_node, children]
        expect(listener1).to receive(:before_subnodes).with(*args)
        expect(listener1).to receive(:before_terminal).with(children[0])
        expect(listener1).to receive(:after_terminal).with(children[0])
        expect(listener1).to receive(:after_subnodes).with(nterm_node, children)
        subject.send(:traverse_subnodes, nterm_node)
      end

      it 'should react to the end_visit_nonterminal message' do
        # Notify subscribers when ending the visit of a non-terminal node
        expect(listener1).to receive(:after_non_terminal).with(nterm_node)
        subject.end_visit_nonterminal(nterm_node)
      end
=end
  end # describe
end # module