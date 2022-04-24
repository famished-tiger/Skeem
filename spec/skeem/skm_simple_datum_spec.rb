# frozen_string_literal: true

require 'ostruct'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/skm_simple_datum' # Load the classes under test

module Skeem
  # rubocop: disable Style/OpenStructUse
  describe SkmSimpleDatum do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('fake-symbol') }
    let(:sample_value) { 'sample-value' }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    let(:instance) { SkmSimpleDatum.create(3) }
    subject { SkmSimpleDatum.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'should be initialized with a token and a position' do
        expect { SkmSimpleDatum.new(dummy_token, pos) }.not_to raise_error
      end

      it 'could be created with just a value' do
        expect { SkmSimpleDatum.create(3) }.not_to raise_error
        expect(instance).to be_kind_of(SkmSimpleDatum)
        expect(instance.value).to eq(3)
      end

      it 'should know its token' do
        expect(subject.token).to eq(dummy_token)
      end

      it 'should know its value' do
        expect(subject.value).to eq(sample_value)
      end

      it "should know the token's symbol" do
        expect(subject.symbol).to eq(dummy_symbol)
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { double('fake-runtime') }

      it 'should assert that it is equal to itself' do
        expect(subject).to eq(subject)
      end

      it 'should assert the equality by value' do
        # Comparison with other instances
        expect(instance).to eq(SkmSimpleDatum.create(3))
        expect(instance).not_to eq(SkmSimpleDatum.create('foo'))

        # Comparison with PORO values
        expect(instance).to eq(3)
        expect(instance).not_to eq('foo')
      end

      it 'should be equivalent to itself' do
        expect(subject).to be_eqv(subject)
      end

      it 'should be equivalent by value' do
        same = SkmSimpleDatum.create(3)
        expect(instance).to be_eqv(same)
      end

      it 'should be Skeem equal to itself' do
        expect(subject).to be_skm_equal(subject)
      end

      it 'should be Skeem equal by value' do
        same = SkmSimpleDatum.create(3)
        expect(instance).to be_skm_equal(same)
      end

      it 'should be self-evaluating' do
        expect(subject.evaluate(runtime)).to be_equal(subject)
      end

      it 'should be self-quasiquoting' do
        expect(subject.quasiquote(runtime)).to be_equal(subject)
      end

      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmSimpleDatum: sample-value>')
      end

      it 'should respond to visitor' do
        visitor = double('fake-visitor')
        expect(visitor).to receive(:visit_simple_datum).with(subject)
        expect { subject.accept(visitor) }.not_to raise_error
      end
    end # context
  end # describe

  describe SkmBoolean do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('BOOLEAN') }
    let(:sample_value) { false }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmBoolean.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'should be initialized with a token and a position' do
        expect { SkmBoolean.new(dummy_token, pos) }.not_to raise_error
      end

      it 'should react positively to boolean? predicate' do
        expect(subject).to be_boolean
      end
    end # context

    context 'Provided services:' do
      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmBoolean: false>')
      end
    end # context
  end # describe

  describe SkmNumber do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('dummy') }
    let(:sample_value) { 0.5100 }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmNumber.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'should be initialized with a token and a position' do
        expect { SkmNumber.new(dummy_token, pos) }.not_to raise_error
      end
    end # context

    context 'Provided services:' do
      it 'should react positively to number? predicate' do
        expect(subject).to be_number
      end

      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmNumber: 0.51>')
      end
    end # context
  end # describe

  describe SkmReal do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('dummy') }
    let(:sample_value) { 0.5100 }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmReal.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'should react positively to number? predicate' do
        expect(subject).to be_number
      end

      it 'should react positively to real? predicate' do
        expect(subject).to be_real
      end

      it 'should react negatively to exact? predicate' do
        expect(subject).not_to be_exact
      end

      it 'should implement the eqv? predicate' do
        same = SkmReal.create(0.51)
        different = SkmReal.create(1.21)

        expect(subject).to be_eqv(subject)
        expect(subject).to be_eqv(same)
        expect(subject).not_to be_eqv(different)
      end
    end # context
  end # describe

  describe SkmInteger do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('dummy') }
    let(:sample_value) { 3 }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmInteger.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'should react positively to number? predicate' do
        expect(subject).to be_number
      end

      it 'should react positively to real? predicate' do
        expect(subject).to be_real
      end

      it 'should react positively to integer? predicate' do
        expect(subject).to be_real
      end

      it 'should react positively to exact? predicate' do
        expect(subject).to be_exact
      end

      it 'should implement the eqv? predicate' do
        three = SkmInteger.create(3)
        real3 = SkmReal.create(3.0)
        four = SkmInteger.create(4)

        expect(subject).to be_eqv(three)
        expect(subject).not_to be_eqv(real3)
        expect(subject).not_to be_eqv(four)
      end
    end # context
  end # describe

  describe SkmString do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('dummy') }
    let(:sample_value) { 'Hello' }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmString.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'should react positively to string? predicate' do
        expect(subject).to be_string
      end

      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmString: Hello>')
      end
    end # context
  end # describe

  describe SkmIdentifier do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('dummy') }
    let(:sample_value) { 'this-is-it!' }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmIdentifier.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'could be initialized with a token and a position' do
        expect { SkmIdentifier.new(dummy_token, pos) }.not_to raise_error
      end

      it 'could be initialized with a token, a position and a flag' do
        expect { SkmIdentifier.new(dummy_token, pos, true) }.not_to raise_error
      end

      it 'should know whether it is used as a variable name' do
        expect(subject.is_var_name).to eq(false)

        instance = SkmIdentifier.new(dummy_token, pos, true)
        expect(instance.is_var_name).to eq(true)
      end

      it 'should react positively to symbol? predicate' do
        expect(subject).to be_symbol
      end

      it 'should react to verbatim? predicate' do
        expect(subject).to be_verbatim
        instance = SkmIdentifier.new(dummy_token, pos, true)
        expect(instance).not_to be_verbatim
      end

      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmIdentifier: this-is-it!>')
      end
    end # context
  end # describe
  # rubocop: enable Style/OpenStructUse
end # module
