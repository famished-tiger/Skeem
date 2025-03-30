# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/s_expr_nodes'
require_relative '../../lib/skeem/skm_unary_expression' # Load the classes under test

module Skeem
  describe SkmUnaryExpression do
    let(:pos) { double('fake-position') }
    let(:sample_child) { double('fake-child') }

    subject(:unary_expr) { described_class.new(pos, sample_child) }

    context 'Initialization:' do
      it 'is initialized with a position and a child element' do
        expect { described_class.new(pos, sample_child) }.not_to raise_error
      end

      it 'knows its child' do
        expect(unary_expr.child).to eq(sample_child)
      end
    end # context

    context 'Provided basic services:' do
      it 'responds to visitor' do
        visitor = double('fake-visitor')
        expect(visitor).to receive(:visit_unary_expression).with(unary_expr)
        expect { unary_expr.accept(visitor) }.not_to raise_error
      end
    end # context
  end # describe

  describe SkmQuotation do
    include DatumDSL

    let(:sample_literal) { string('foo') }

    subject(:quotation) { described_class.new(sample_literal) }

    context 'Initialization:' do
      it 'is initialized with a Skeem element' do
        expect { described_class.new(sample_literal) }.not_to raise_error
      end

      it 'knows its datum' do
        expect(quotation.datum).to equal(sample_literal)
        expect(quotation.datum).to equal(quotation.child)
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      # it 'returns the child(datum) at evaluation' do
        # expect(unary_expr.evaluate(runtime)).to equal(unary_expr.child)
      # end

      it 'implements quasiquotation' do
        # Case 1: child is idempotent with quasiquote
        expect(quotation.quasiquote(runtime)).to equal(quotation)

        # Case 2: quasiquoted child is different
        child = double('fake-child')
        allow(child).to receive(:quasiquote).with(runtime).and_return(integer(3))
        instance = described_class.new(child)
        expect(instance.child).to eq(child)
        quasi_result = instance.quasiquote(runtime)
        expect(quasi_result.child.value).to eq(3)
      end

      it 'returns its text representation' do
        txt1 = '<Skeem::SkmQuotation: <Skeem::SkmString: foo>>'
        expect(quotation.inspect).to eq(txt1)
      end
    end # context
  end # describe


  describe SkmQuasiquotation do
    include DatumDSL

    let(:sample_literal) { string('foo') }

    subject(:quasiquote) { described_class.new(sample_literal) }

    context 'Initialization:' do
      it 'is initialized with a Skeem element' do
        expect { described_class.new(sample_literal) }.not_to raise_error
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      it 'returns the child(template) at evaluation' do
        expect(quasiquote.evaluate(runtime)).to equal(quasiquote.child)
      end

      it 'accepts quasiquotation' do
        # Case 1: child is idempotent with quasiquote
        expect(quasiquote.quasiquote(runtime)).to equal(quasiquote.child)

        # Case 2: quasiquoted child is different
        child = double('fake-child')
        allow(child).to receive(:quasiquote).with(runtime).and_return(integer(3))
        instance = described_class.new(child)
        expect(instance.child).to eq(child)
        quasi_result = instance.quasiquote(runtime)
        expect(quasi_result).to eq(3)
      end

      it 'returns its text representation' do
        txt1 = '<Skeem::SkmQuasiquotation: <Skeem::SkmString: foo>>'
        expect(quasiquote.inspect).to eq(txt1)
      end
    end # context
  end # describe

  describe SkmUnquotation do
    include DatumDSL

    let(:sample_literal) { string('foo') }

    subject(:unquote) { described_class.new(sample_literal) }

    context 'Initialization:' do
      it 'is initialized with a Skeem element' do
        expect { described_class.new(sample_literal) }.not_to raise_error
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      it 'returns the child(template) at evaluation' do
        expect(unquote.evaluate(runtime)).to equal(unquote.child)
      end

      it 'accepts quasiquotation' do
        # Case 1: child is idempotent with evaluate
        expect(unquote.quasiquote(runtime)).to equal(unquote.child)

        # Case 2: quasiquoted child is different
        child = double('fake-child')
        allow(child).to receive(:unquoted!)
        allow(child).to receive(:evaluate).with(runtime).and_return(integer(3))
        instance = described_class.new(child)
        expect(instance.child).to eq(child)
        quasi_result = instance.quasiquote(runtime)
        expect(quasi_result).to eq(3)
      end

      it 'returns its text representation' do
        txt1 = '<Skeem::SkmUnquotation: <Skeem::SkmString: foo>>'
        expect(unquote.inspect).to eq(txt1)
      end
    end # context
  end # describe

  describe SkmVariableReference do
    include DatumDSL

    let(:pos) { double('fake-position') }
    let(:sample_var) { identifier('three') }

    subject(:var_ref) { described_class.new(pos, sample_var) }

    context 'Initialization:' do
      it 'is initialized with a position and a symbol' do
        expect { described_class.new(pos, sample_var) }.not_to raise_error
      end

      it 'knows its variable' do
        expect(var_ref.variable).to equal(sample_var)
        expect(var_ref.variable).to equal(var_ref.child)
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      before do
        runtime.add_binding('three', integer(3))
      end

      it "returns the variable's value at evaluation" do
        expect(var_ref.evaluate(runtime)).to eq(3)
      end

      it 'returns itself at quasiquotation' do
        expect(var_ref.quasiquote(runtime)).to equal(var_ref)
      end

      it 'returns its text representation' do
        txt1 = '<Skeem::SkmVariableReference: <Skeem::SkmIdentifier: three>>'
        expect(var_ref.inspect).to eq(txt1)
      end
    end # context
  end # describe
end # module
