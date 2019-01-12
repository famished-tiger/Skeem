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
    subject { SkmPair.new(sample_car, sample_cdr) }

    context 'Initialization:' do
      it 'should be initialized with two arguments' do
        expect { SkmPair.new(sample_car, sample_cdr) }.not_to raise_error
      end

      it "should know its 'car' field" do
        expect(subject.car).to eq(sample_car)
      end

      it "should know its 'cdr' field" do
        expect(subject.cdr).to eq(sample_cdr)
      end

      # Default (overridable) behavior of SkmElement
      it 'should react by default to predicates' do
        expect(subject).to be_list
        expect(subject).not_to be_null
        expect(subject).to be_pair
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(Environment.new) }
      let(:list_length_2) { SkmPair.new(integer(10), subject) }
      let(:quirk_element) { double('three') }
      let(:quirk_members) { [integer(10), quirk_element] }

      it 'should know its length' do
        expect(subject.length).to eq(1)

        # Use a list of length 2
        expect(list_length_2.length).to eq(2)
      end

      it 'should respond false to `eqv?` message' do
        expect(subject.eqv?(subject)).to eq(false)
      end

      it 'should be Skeem equal to itself' do
        expect(subject.skm_equal?(subject)).to eq(true)
      end


      it 'should be equal to other pair when their car and cdr match' do
        instance = SkmPair.new(sample_car, sample_cdr)
        expect(subject.skm_equal?(instance)).to eq(true)
        instance.car = integer(4)
        expect(subject.skm_equal?(instance)).to eq(false)
        instance.car = sample_car
        instance.cdr = subject
        expect(subject.skm_equal?(instance)).to eq(false)
      end

      it 'should clone itself after member evaluation' do
        # subject contains self-evaluating members
        expect(subject.clone_evaluate(runtime)).to eq(subject)

        # Make pair improper...
        subject.cdr = nil
        expect(subject.clone_evaluate(runtime)).to eq(subject)

        subject.cdr = integer(4)
        expect(subject.clone_evaluate(runtime)).to eq(subject)

        successor = SkmPair.new(string('Hi'), boolean(false))
        subject.cdr = successor
        expect(subject.clone_evaluate(runtime)).to eq(subject)
      end

      it 'should convert itself into an array' do
        expect(subject.to_a).to eq([sample_car])

        # Use a list of length 2
        expect(list_length_2.to_a).to eq([integer(10), sample_car])
      end

      it 'should return the last element of a list' do
         expect(subject.last).to eq(sample_car)
         expect(list_length_2.last).to eq(sample_car)
      end

      it 'should append a new element to a list' do
        subject.append(integer(4))
        expect(subject.length).to eq(2)
        expect(subject.to_a).to eq([3, 4])
      end

      it 'should create a list from an array' do
        # List of length 0
        array0 = []
        list = SkmPair.create_from_a(array0)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(0)
        expect(list.to_a).to eq(array0)

        # List of length 1
        array1 = [boolean(false)]
        list = SkmPair.create_from_a(array1)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(1)
        expect(list.to_a).to eq(array1)

        # List of length 2
        array2 = [identifier('f'), identifier('g')]
        list = SkmPair.create_from_a(array2)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(2)
        expect(list.to_a).to eq(array2)

        # List of length 3
        array3 = [integer(4), integer(5), integer(6)]
        list = SkmPair.create_from_a(array3)
        expect(list).to be_list # It's a proper list...
        expect(list.length).to eq(3)
        expect(list.to_a).to eq([4, 5, 6])
      end

      it 'should support the each method' do
        my_list = SkmPair.new('w', SkmPair.new('o', SkmPair.new('w', SkmEmptyList.instance)))
        text = ''
        my_list.each { |ch| text << ch.upcase }
        expect(text).to eq('WOW')
      end

      it 'should implement the verbatim predicate' do
        expect(subject).to be_verbatim
        subject.cdr = nil
        expect(subject).to be_verbatim
        instance = SkmPair.new(string('Hi'), SkmEmptyList.instance)
        subject.cdr = instance
        expect(subject).to be_verbatim
        bad_end = double('fake_end')
        instance.cdr = bad_end
        expect(bad_end).to receive(:verbatim?).and_return(false)
        expect(subject).not_to be_verbatim
        bad_datum = double('fake-datum')
        expect(bad_datum).to receive(:verbatim?).and_return(false)
        instance.car = bad_datum
        expect(subject).not_to be_verbatim
      end

      it 'should evaluate its members' do
        # subject contains simple literals
        expect(subject.evaluate(runtime)).to eq(subject)

        # Check that members receive the 'evaluate' message
        expect(quirk_element).to receive(:evaluate).with(runtime).and_return(integer(3))
        instance = SkmPair.create_from_a(quirk_members)
        expect { instance.evaluate(runtime) }.not_to raise_error
      end

      it 'should quasiquote its members' do
        # subject contains simple literals
        expect(subject.quasiquote(runtime)).to eq(subject)

        # Check that members receive the 'quasiquote' message
        expect(quirk_element).to receive(:quasiquote).with(runtime).and_return(integer(3))
        instance = SkmPair.create_from_a(quirk_members)
        expect { instance.quasiquote(runtime) }.not_to raise_error
      end

      it "should reply to visitor's 'accept' message" do
        visitor = double('fake-visitor')
        expect(visitor).to receive(:visit_pair).with(subject)
        expect { subject.accept(visitor) }.not_to raise_error
      end

      it 'should return its representation upon inspection' do
        predicted = '<Skeem::SkmPair: <Skeem::SkmInteger: 3>>'
        expect(subject.inspect).to eq(predicted)

        predicted = '<Skeem::SkmPair: <Skeem::SkmInteger: 10>, <Skeem::SkmInteger: 3>>'
        expect(list_length_2.inspect).to eq(predicted)
      end
    end # context

  end # describe
end # module