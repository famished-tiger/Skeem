require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/skm_compound_datum' # Load the classes under test

module Skeem
  describe SkmCompoundDatum do
    include DatumDSL

    let(:sample_members) { [1, 2, 3] }
    let(:sample_members) { [integer(1), integer(2), integer(3)] }
    subject { SkmCompoundDatum.new(sample_members) }

    context 'Initialization:' do
      it 'should be initialized with its members' do
        expect{ SkmCompoundDatum.new(sample_members) }.not_to raise_error
      end

      it 'should know its members' do
        expect(subject.members).to eq(sample_members)

        other = SkmCompoundDatum.new([])
        expect(other.members).to be_empty
      end
    end # context

    context 'Provided basic services:' do
      it 'should assert that it is equal to itself' do
        expect(subject).to eq(subject)
      end

     it 'should assert the equality by member values' do
        # Comparison with other instances
        expect(subject).to eq(SkmCompoundDatum.new(sample_members))
        expect(subject).not_to eq(SkmCompoundDatum.new([]))
        expect(subject).not_to eq(SkmCompoundDatum.new(sample_members.rotate))

        # Comparison with array of values
        expect(subject).to eq(sample_members)
        expect(subject).not_to eq(sample_members.rotate)
      end

      it 'should respond to visitor' do
        visitor = double('fake-visitor')
        expect(visitor).to receive(:visit_compound_datum).with(subject)
        expect { subject.accept(visitor) }.not_to raise_error
      end
      
      it 'should return its text representation' do
        txt1 = '<Skeem::SkmCompoundDatum: <Skeem::SkmInteger: 1>,'
        txt2 = '<Skeem::SkmInteger: 2>, <Skeem::SkmInteger: 3>>'
        expect(subject.inspect).to eq(txt1 + ' ' + txt2)
      end     
    end # context

    context 'Provided runtime services:' do
      let(:quirk_datum) { double('two') }
      let(:quirk_members) { [integer(1), quirk_datum, integer(3)] }
      let(:runtime) { double('fake-runtime') }

      it 'should evaluate its members' do
        # subject contains simple literals
        expect(subject.evaluate(runtime)).to eq(subject)

        # Check that members receive the 'evaluate' message
        expect(quirk_datum).to receive(:evaluate).with(runtime).and_return(integer(2))
        instance = SkmCompoundDatum.new(quirk_members)
        expect(instance.evaluate(runtime)).to eq(subject)
      end

      it 'should quasiquoting its members' do
        # subject contains simple literals
        expect(subject.quasiquote(runtime)).to eq(subject)

        # Check that members receive the 'quasiquote' message
        expect(quirk_datum).to receive(:quasiquote).with(runtime).and_return(integer(2))
        instance = SkmCompoundDatum.new(quirk_members)
        expect(instance.quasiquote(runtime)).to eq(subject)
      end
    end # context
  end # describe
  
  describe SkmVector do
    let(:sample_members) { [1, 2, 3] }
    subject { SkmVector.new(sample_members) }

    context 'Initialization:' do
      it 'should be initialized with its members' do
        expect{ SkmVector.new(sample_members) }.not_to raise_error
      end
      
      it 'should react positively to vector? predicate' do
        expect(subject).to be_vector
      end      
    end # context
  end # describe
end # module