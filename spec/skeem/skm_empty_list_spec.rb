require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/skm_empty_list' # Load the class under test

module Skeem
  describe SkmEmptyList do
    subject { SkmEmptyList.instance }

    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { SkmEmptyList.instance }.not_to raise_error
      end

      # Default (overridable) behavior of SkmElement
      it 'should react by default to predicates' do
        expect(subject).to be_list
        expect(subject).to be_null
        expect(subject).not_to be_pair
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { double('fake-runtime') }

      it "should return itself when receiving 'evaluate' message" do
        expect(subject.evaluate(runtime)).to eq(subject)
      end

      it "should return itself receiving 'quasiquote' message" do
        expect(subject.quasiquote(runtime)).to eq(subject)
      end

      it "should reply to visitor's 'accept' message" do
        visitor = double('fake-visitor')
        expect(visitor).to receive(:visit_empty_list).with(subject)      
        expect { subject.accept(visitor) }.not_to raise_error
      end
      
      it 'should return its representation upon inspection' do
        predicted = '<Skeem::SkmEmptyList: ()>'
        expect(subject.inspect).to eq(predicted)
      end
    end # context
  end # describe
end # module