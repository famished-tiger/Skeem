require 'ostruct'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/s_expr_nodes' # Load the classes under test

module Skeem
  describe SkmElement do
    let(:pos) {double('fake-position') }
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
      end
    end # context
  end # describe

describe SkmTerminal do
    let(:pos) { double('fake-position') }
    let(:dummy_symbol) { double('fake-symbol') }
    let(:sample_value) { 'sample-value' }
    let(:dummy_token) do
      obj = OpenStruct.new
      obj.terminal = dummy_symbol
      obj.lexeme = sample_value
      obj
    end
    subject { SkmTerminal.new(dummy_token, pos) }

    context 'Initialization:' do
      it 'should be initialized with a token and a position' do
        expect { SkmTerminal.new(dummy_token, pos) }.not_to raise_error
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
    end

    context 'Provided services:' do
      it 'should return its text representation' do
        expect(subject.inspect).to eq("<Skeem::SkmTerminal: sample-value>")
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
    end

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
    end

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
    end
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
    end
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
    end
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
      it 'should react positively to symbol? predicate' do
        expect(subject).to be_symbol
      end

      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmIdentifier: this-is-it!>')
      end
    end # context
  end # describe

  describe SkmList do
    let(:sample_members) { [1, 2, 3] }

    subject { SkmList.new(sample_members) }

    context 'Initialization:' do
      it 'should be initialized with its members' do
        expect{ SkmList.new(sample_members) }.not_to raise_error
      end

      it 'should know its members' do
        expect(subject.members).to eq(sample_members)
        
        other = SkmList.new([])
        expect(other.members).to be_empty
      end
    end # context

    context 'Provided services:' do
      it 'should retrieve its first member' do
        expect(subject.first).to eq(1)
        expect(subject.head).to eq(1)
      end

      it 'should retrieve its tail members' do
        expect(subject.tail.inspect).to eq('<Skeem::SkmList: 2, 3>')
        expect(subject.rest.inspect).to eq('<Skeem::SkmList: 2, 3>')
      end

      it 'should return its text representation' do
        expect(subject.inspect).to eq('<Skeem::SkmList: 1, 2, 3>')
      end
    end # context
  end # describe


  describe SkmDefinition do
    let(:pos) { double('fake-position') }
    let(:sample_symbol) { SkmIdentifier.create('this-is-it!') }
    let(:sample_expr) { SkmInteger.create(10) }

    subject { SkmDefinition.new(pos, sample_symbol, sample_expr) }

    context 'Initialization:' do
      it 'should be initialized with a symbol and an expression' do
        expect{ SkmDefinition.new(pos, sample_symbol, sample_expr) }.not_to raise_error
      end

      it 'should know its variable' do
        expect(subject.variable).to eq(sample_symbol)
      end

      it 'should know its expression' do
        expect(subject.expression).to eq(sample_expr)
      end
    end # context

    context 'Provided services:' do
      it 'should return its text representation' do
        txt1 = '<Skeem::SkmDefinition: <Skeem::SkmIdentifier: this-is-it!>,'
        txt2 = ' <Skeem::SkmInteger: 10>>'
        expect(subject.inspect).to eq(txt1 + txt2)
      end
    end # context
  end # describe

  describe SkmVariableReference do
    let(:pos) { double('fake-position') }
    let(:sample_symbol) { SkmIdentifier.create('this-is-it!') }

    subject { SkmVariableReference.new(pos, sample_symbol) }

    context 'Initialization:' do
      it 'should be initialized with a position and a symbol' do
        expect{ SkmVariableReference.new(pos, sample_symbol) }.not_to raise_error
      end

      it 'should know its variable' do
        expect(subject.variable).to eq(sample_symbol)
      end
    end # context

    context 'Provided services:' do
      it 'should return its text representation' do
        txt1 = '<Skeem::SkmVariableReference: <Skeem::SkmIdentifier: this-is-it!>>'
        expect(subject.inspect).to eq(txt1)
      end
    end # context
  end # describe

  describe ProcedureCall do
     let(:pos) { double('fake-position') }
    let(:operator) { SkmIdentifier.create('+') }
    let(:operands) { [1, 2, 3] }

    subject { ProcedureCall.new(pos, operator, operands) }

    context 'Initialization:' do
      it 'should be initialized with an operator symbol and its operands' do
        expect{ ProcedureCall.new(pos, operator, operands) }.not_to raise_error
      end

      it 'should know its operator' do
        expect(subject.operator).to eq(operator)
      end

      it 'should know its operands' do
        expect(subject.operands.inspect).to eq('<Skeem::SkmList: 1, 2, 3>')
      end
    end # context

    context 'Provided services:' do
      it 'should return its text representation' do
        txt1 = '<Skeem::ProcedureCall: <Skeem::SkmIdentifier: +>, '
        txt2 = '@operands <Skeem::SkmList: 1, 2, 3>>'
        expect(subject.inspect).to eq(txt1 + txt2)
      end
    end # context
  end # describe

  describe SkmCondition do
    let(:pos) { double('fake-position') }
    let(:s_test) { double('fake-test') }
    let(:s_consequent) { double('fake-consequent') }
    let(:s_alt) { double('fake-alternate') }

    subject { SkmCondition.new(pos, s_test, s_consequent, s_alt) }

    context 'Initialization:' do
      it 'should be initialized with a pos and 3 expressions' do
        expect{ SkmCondition.new(pos, s_test, s_consequent, s_alt) }.not_to raise_error
      end

      it 'should know its test' do
        expect(subject.test).to eq(s_test)
      end

      it 'should know its consequent' do
        expect(subject.consequent).to eq(s_consequent)
      end

      it 'should know its alternate' do
        expect(subject.alternate).to eq(s_alt)
      end
    end # context

    context 'Provided services:' do
      it 'should return its text representation' do
        txt1 = '<Skeem::SkmCondition: @test #<Double "fake-test">, '
        txt2 = '@consequent #<Double "fake-consequent">, '
        txt3 = '@alternate #<Double "fake-alternate">>'
        expect(subject.inspect).to eq(txt1 + txt2 + txt3)
      end
    end # context
  end # describe

  describe SkmLambda do
    let(:pos) { double('fake-position') }
    let(:s_formals) { double('fake-formals') }
    let(:s_defs) { double('fake-definitions') }
    let(:s_sequence) { double('fake-sequence') }
    let(:s_body) do { defs: s_defs, sequence: s_sequence } end

    subject { SkmLambda.new(pos, s_formals, s_body) }
    
    context 'Initialization:' do
      it 'should be initialized with a pos and 3 expressions' do
        expect{ SkmLambda.new(pos, s_formals, s_body) }.not_to raise_error
      end

      it 'should know its formals' do
        expect(subject.formals).to eq(s_formals)
      end

      it 'should know its definitions' do
        expect(subject.definitions).to eq(s_defs)
      end

      it 'should know its sequence' do
        expect(subject.sequence).to eq(s_sequence)
      end
    end # context

    context 'Provided services:' do
      it 'should return its text representation' do
        txt1 = '<Skeem::SkmLambda: @formals #<Double "fake-formals">, '
        txt2 = '@definitions #<Double "fake-definitions">, '
        txt3 = '@sequence #<Double "fake-sequence">>'
        expect(subject.inspect).to eq(txt1 + txt2 + txt3)
      end
    end # context
  end # describe
end # module
