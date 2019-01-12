require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/skm_element' # Load the class under test

module Skeem
  describe SkmElement do
    let(:pos) { double('fake-position') }
    subject { SkmElement.new(pos) }

    context 'Initialization:' do
      it 'should be initialized with a position' do
        expect { SkmElement.new(pos) }.not_to raise_error
      end

      it 'should know its position' do
        expect(subject.position).to eq(pos)
      end

      # Default (overridable) behavior of SkmElement
      it 'should react by default to predicates' do
        expect(subject).not_to be_boolean
        expect(subject).not_to be_number
        expect(subject).not_to be_real
        expect(subject).not_to be_integer
        expect(subject).not_to be_string
        expect(subject).not_to be_symbol
        expect(subject).not_to be_list
        expect(subject).not_to be_null
        expect(subject).not_to be_pair
        expect(subject).not_to be_vector
        expect(subject).not_to be_verbatim
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { double('fake-runtime') }
      let(:visitor) { double('fake-visitor') }
      let(:not_implemented) { NotImplementedError }
      
      it 'should be equivalent to itself' do
        expect(subject).to be_eqv(subject)
        expect(subject).not_to be_eqv(subject.clone)
      end     

      it "should ignore the 'done!' message" do
        expect { subject.done! }.not_to raise_error
      end

      it "should ignore the 'quoted!' message" do
        expect { subject.quoted! }.not_to raise_error
      end

      it "should ignore the 'unquoted!' message" do
        expect { subject.unquoted! }.not_to raise_error
      end
      
      it "should complain when receiving 'skm_equal?' message" do
        msg = 'Missing implementation of method Skeem::SkmElement#skm_equal?'
        expect { subject.skm_equal?('omg') }.to raise_error(NotImplementedError, msg)
      end       

      it "should complain when receiving 'evaluate' message" do
        expect { subject.evaluate(runtime) }.to raise_error(not_implemented)
      end

      it "should complain when receiving 'quasiquote' message" do
        expect { subject.quasiquote(runtime) }.to raise_error(not_implemented)
      end

      it "should complain when receiving 'accept' message" do
        expect { subject.accept(visitor) }.to raise_error(not_implemented)
      end
    end # context
  end # describe
end # module