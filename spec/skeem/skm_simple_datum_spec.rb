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
    let(:instance) { described_class.create(3) }

    subject(:datum) { described_class.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'is initialized with a token and a position' do
        expect { described_class.new(dummy_token, pos) }.not_to raise_error
      end

      it 'could be created with just a value' do
        expect { described_class.create(3) }.not_to raise_error
        expect(instance).to be_a(described_class)
        expect(instance.value).to eq(3)
      end

      it 'knows its token' do
        expect(datum.token).to eq(dummy_token)
      end

      it 'knows its value' do
        expect(datum.value).to eq(sample_value)
      end

      it "knows the token's symbol" do
        expect(datum.symbol).to eq(dummy_symbol)
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { double('fake-runtime') }

      it 'asserts that it is equal to itself' do
        expect(datum).to eq(datum)
      end

      it 'asserts the equality by value' do
        # Comparison with other instances
        expect(instance).to eq(described_class.create(3))
        expect(instance).not_to eq(described_class.create('foo'))

        # Comparison with PORO values
        expect(instance).to eq(3)
        expect(instance).not_to eq('foo')
      end

      it 'is equivalent to itself' do
        expect(datum).to be_eqv(datum)
      end

      it 'is equivalent by value' do
        same = described_class.create(3)
        expect(instance).to be_eqv(same)
      end

      it 'is Skeem equal to itself' do
        expect(datum).to be_skm_equal(datum)
      end

      it 'is Skeem equal by value' do
        same = described_class.create(3)
        expect(instance).to be_skm_equal(same)
      end

      it 'is self-evaluating' do
        expect(datum.evaluate(runtime)).to equal(datum)
      end

      it 'is self-quasiquoting' do
        expect(datum.quasiquote(runtime)).to equal(datum)
      end

      it 'returns its text representation' do
        expect(datum.inspect).to eq('<Skeem::SkmSimpleDatum: sample-value>')
      end

      it 'responds to visitor' do
        visitor = double('fake-visitor')
        allow(visitor).to receive(:visit_simple_datum).with(datum)
        expect { datum.accept(visitor) }.not_to raise_error
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

    subject(:boolean) { described_class.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'is initialized with a token and a position' do
        expect { described_class.new(dummy_token, pos) }.not_to raise_error
      end

      it 'reacts positively to boolean? predicate' do
        expect(boolean).to be_boolean
      end
    end # context

    context 'Provided services:' do
      it 'returns its text representation' do
        expect(boolean.inspect).to eq('<Skeem::SkmBoolean: false>')
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

    subject(:number) { described_class.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'is initialized with a token and a position' do
        expect { described_class.new(dummy_token, pos) }.not_to raise_error
      end
    end # context

    context 'Provided services:' do
      it 'reacts positively to number? predicate' do
        expect(number).to be_number
      end

      it 'returns its text representation' do
        expect(number.inspect).to eq('<Skeem::SkmNumber: 0.51>')
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

    subject(:real) { described_class.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'reacts positively to number? predicate' do
        expect(real).to be_number
      end

      it 'reacts positively to real? predicate' do
        expect(real).to be_real
      end

      it 'reacts negatively to exact? predicate' do
        expect(real).not_to be_exact
      end

      it 'implements the eqv? predicate' do
        same = described_class.create(0.51)
        different = described_class.create(1.21)

        expect(real).to be_eqv(real)
        expect(real).to be_eqv(same)
        expect(real).not_to be_eqv(different)
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

    subject(:integer) { described_class.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'reacts positively to number? predicate' do
        expect(integer).to be_number
      end

      it 'reacts positively to real? predicate' do
        expect(integer).to be_real
      end

      it 'reacts positively to integer? predicate' do
        expect(integer).to be_real
      end

      it 'reacts positively to exact? predicate' do
        expect(integer).to be_exact
      end

      it 'implements the eqv? predicate' do
        three = described_class.create(3)
        real3 = SkmReal.create(3.0)
        four = described_class.create(4)

        expect(integer).to be_eqv(three)
        expect(integer).not_to be_eqv(real3)
        expect(integer).not_to be_eqv(four)
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

    subject(:string) { described_class.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'reacts positively to string? predicate' do
        expect(string).to be_string
      end

      it 'returns its text representation' do
        expect(string.inspect).to eq('<Skeem::SkmString: Hello>')
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

    subject(:identifier) { described_class.new(dummy_token, pos) }

    context 'Provided services:' do
      it 'could be initialized with a token and a position' do
        expect { described_class.new(dummy_token, pos) }.not_to raise_error
      end

      it 'could be initialized with a token, a position and a flag' do
        expect { described_class.new(dummy_token, pos, true) }.not_to raise_error
      end

      it 'knows whether it is used as a variable name' do
        expect(identifier.is_var_name).to be(false)

        instance = described_class.new(dummy_token, pos, true)
        expect(instance.is_var_name).to be(true)
      end

      it 'reacts positively to symbol? predicate' do
        expect(identifier).to be_symbol
      end

      it 'reacts to verbatim? predicate' do
        expect(identifier).to be_verbatim
        instance = described_class.new(dummy_token, pos, true)
        expect(instance).not_to be_verbatim
      end

      it 'returns its text representation' do
        expect(identifier.inspect).to eq('<Skeem::SkmIdentifier: this-is-it!>')
      end
    end # context
  end # describe
  # rubocop: enable Style/OpenStructUse
end # module
