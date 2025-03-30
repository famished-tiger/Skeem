# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/skm_element' # Load the class under test

module Skeem
  describe SkmElement do
    let(:pos) { double('fake-position') }

    subject(:element) { described_class.new(pos) }

    context 'Initialization:' do
      it 'is initialized with a position' do
        expect { described_class.new(pos) }.not_to raise_error
      end

      it 'knows its position' do
        expect(element.position).to eq(pos)
      end

      # Default (overridable) behavior of SkmElement
      it 'reacts by default to predicates' do
        expect(element).not_to be_boolean
        expect(element).not_to be_number
        expect(element).not_to be_real
        expect(element).not_to be_integer
        expect(element).not_to be_string
        expect(element).not_to be_symbol
        expect(element).not_to be_list
        expect(element).not_to be_null
        expect(element).not_to be_pair
        expect(element).not_to be_vector
        expect(element).not_to be_verbatim
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { double('fake-runtime') }
      let(:visitor) { double('fake-visitor') }
      let(:not_implemented) { NotImplementedError }

      it 'is equivalent to itself' do
        expect(element).to be_eqv(element)
        expect(element).not_to be_eqv(element.clone)
      end

      it "ignores the 'done!' message" do
        expect { element.done! }.not_to raise_error
      end

      it "ignores the 'quoted!' message" do
        expect { element.quoted! }.not_to raise_error
      end

      it "ignores the 'unquoted!' message" do
        expect { element.unquoted! }.not_to raise_error
      end

      it "complains when receiving 'skm_equal?' message" do
        msg = 'Missing implementation of method Skeem::SkmElement#skm_equal?'
        expect { element.skm_equal?('omg') }.to raise_error(NotImplementedError, msg)
      end

      it "complains when receiving 'evaluate' message" do
        expect { element.evaluate(runtime) }.to raise_error(not_implemented)
      end

      it "complains when receiving 'quasiquote' message" do
        expect { element.quasiquote(runtime) }.to raise_error(not_implemented)
      end

      it "complains when receiving 'accept' message" do
        expect { element.accept(visitor) }.to raise_error(not_implemented)
      end
    end # context
  end # describe
end # module
