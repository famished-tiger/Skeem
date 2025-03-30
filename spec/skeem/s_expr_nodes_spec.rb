# frozen_string_literal: true

require 'ostruct'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/runtime'
require_relative '../../lib/skeem/primitive/primitive_builder'
require_relative '../../lib/skeem/s_expr_nodes' # Load the classes under test

module Skeem
  describe ProcedureCall do
    let(:pos) { double('fake-position') }
    let(:operator) { SkmIdentifier.create('+') }
    let(:operands) { [1, 2, 3] }

    subject(:proc_call) { described_class.new(pos, operator, operands) }

    context 'Initialization:' do
      it 'is initialized with an operator symbol and its operands' do
        expect { described_class.new(pos, operator, operands) }.not_to raise_error
      end

      it 'knows its operator' do
        expect(proc_call.operator).to eq(operator)
      end

      it 'knows its operands' do
        expect(proc_call.operands.inspect).to eq('<Skeem::SkmPair: 1, 2, 3>')
      end
    end # context

    context 'Provided services:' do
      it 'returns its text representation' do
        txt1 = '<Skeem::ProcedureCall: <Skeem::SkmIdentifier: +>, '
        txt2 = '@operands <Skeem::SkmPair: 1, 2, 3>>'
        expect(proc_call.inspect).to eq(txt1 + txt2)
      end
    end # context
  end # describe

  describe SkmCondition do
    let(:pos) { double('fake-position') }
    let(:s_test) { double('fake-test') }
    let(:s_consequent) { double('fake-consequent') }
    let(:s_alt) { double('fake-alternate') }

    subject(:condition) { described_class.new(pos, s_test, s_consequent, s_alt) }

    context 'Initialization:' do
      it 'is initialized with a pos and 3 expressions' do
        expect { described_class.new(pos, s_test, s_consequent, s_alt) }.not_to raise_error
      end

      it 'knows its test' do
        expect(condition.test).to eq(s_test)
      end

      it 'knows its consequent' do
        expect(condition.consequent).to eq(s_consequent)
      end

      it 'knows its alternate' do
        expect(condition.alternate).to eq(s_alt)
      end
    end # context

    context 'Provided services:' do
      it 'returns its text representation' do
        txt1 = '<Skeem::SkmCondition: @test #<Double "fake-test">, '
        txt2 = '@consequent #<Double "fake-consequent">, '
        txt3 = '@alternate #<Double "fake-alternate">>'
        expect(condition.inspect).to eq(txt1 + txt2 + txt3)
      end
    end # context
  end # describe

  describe SkmLambdaRep do
    let(:pos) { double('fake-position') }
    let(:s_formals) { double('fake-formals') }
    let(:s_defs) { double('fake-definitions') }
    let(:s_sequence) { double('fake-sequence') }
    let(:s_body) { { defs: s_defs, sequence: s_sequence } }

    subject(:lambda_rep) { described_class.new(pos, s_formals, s_body) }

    context 'Initialization:' do
      it 'is initialized with a pos and 3 expressions' do
        expect { described_class.new(pos, s_formals, s_body) }.not_to raise_error
      end

      it 'knows its formals' do
        expect(lambda_rep.formals).to eq(s_formals)
      end

      it 'knows its definitions' do
        expect(lambda_rep.definitions).to eq(s_defs)
      end

      it 'knows its sequence' do
        expect(lambda_rep.sequence).to eq(s_sequence)
      end
    end # context

    context 'Provided services:' do
      it 'returns its text representation' do
        txt1 = '<Skeem::SkmLambdaRep: @formals #<Double "fake-formals">, '
        txt2 = '@definitions #<Double "fake-definitions">, '
        txt3 = '@sequence #<Double "fake-sequence">>>'
        # Remove "unpredictable" part of actual text
        expectation = lambda_rep.inspect.gsub(/@object_id=[0-9a-z]+, /, '')
        expect(expectation).to eq(txt1 + txt2 + txt3)
      end
    end # context
  end # describe
end # module
