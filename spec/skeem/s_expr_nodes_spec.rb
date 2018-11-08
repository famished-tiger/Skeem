require 'ostruct'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/runtime'
require_relative '../../lib/skeem/s_expr_nodes' # Load the classes under test

module Skeem
  describe SkmDefinition do
    let(:pos) { double('fake-position') }
    let(:sample_symbol) { SkmIdentifier.create('ten') }
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
      let(:runtime) { Runtime.new(Environment.new) }

      it 'should create an entry when evaluating' do
        expect(runtime).not_to include(sample_symbol)
        subject.evaluate(runtime)
        expect(runtime).to include(sample_symbol)
      end
      
      it 'should quasiquote its variable and expression' do
        alter_ego = subject.quasiquote(runtime)
        expect(alter_ego).to eq(subject)        
      end

      it 'should return its text representation' do
        txt1 = '<Skeem::SkmDefinition: <Skeem::SkmIdentifier: ten>,'
        txt2 = ' <Skeem::SkmInteger: 10>>'
        expect(subject.inspect).to eq(txt1 + txt2)
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
