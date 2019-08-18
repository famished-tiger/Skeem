# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/s_expr_nodes'
require_relative '../../lib/skeem/skm_unary_expression' # Load the classes under test

module Skeem
  describe SkmUnaryExpression do
    let(:pos) { double('fake-position') }
    let(:sample_child) { double('fake-child') }

    subject { SkmUnaryExpression.new(pos, sample_child) }

    context 'Initialization:' do
      it 'should be initialized with a position and a child element' do
        expect { SkmUnaryExpression.new(pos, sample_child) }.not_to raise_error
      end

      it 'should know its child' do
        expect(subject.child).to eq(sample_child)
      end
    end # context

    context 'Provided basic services:' do
      it 'should respond to visitor' do
        visitor = double('fake-visitor')
        expect(visitor).to receive(:visit_unary_expression).with(subject)
        expect { subject.accept(visitor) }.not_to raise_error
      end
    end # context
  end # describe

  describe SkmQuotation do
    include DatumDSL

    let(:sample_literal) { string('foo') }

    subject { SkmQuotation.new(sample_literal) }

    context 'Initialization:' do
      it 'should be initialized with a Skeem element' do
        expect { SkmQuotation.new(sample_literal) }.not_to raise_error
      end

      it 'should know its datum' do
        expect(subject.datum).to be_equal(sample_literal)
        expect(subject.datum).to be_equal(subject.child)
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      # it 'should return the child(datum) at evaluation' do
        # expect(subject.evaluate(runtime)).to be_equal(subject.child)
      # end

      it 'should implement quasiquotation' do
        # Case 1: child is idempotent with quasiquote
        expect(subject.quasiquote(runtime)).to be_equal(subject)

        # Case 2: quasiquoted child is different
        child = double('fake-child')
        expect(child).to receive(:quasiquote).with(runtime).and_return(integer(3))
        instance = SkmQuasiquotation.new(child)
        expect(instance.child).to eq(child)
        quasi_result = instance.quasiquote(runtime)
        expect(quasi_result).to eq(3)
      end

      it 'should return its text representation' do
        txt1 = '<Skeem::SkmQuotation: <Skeem::SkmString: foo>>'
        expect(subject.inspect).to eq(txt1)
      end
    end # context
  end # describe


  describe SkmQuasiquotation do
    include DatumDSL

    let(:sample_literal) { string('foo') }

    subject { SkmQuasiquotation.new(sample_literal) }

    context 'Initialization:' do
      it 'should be initialized with a Skeem element' do
        expect { SkmQuasiquotation.new(sample_literal) }.not_to raise_error
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      it 'should return the child(template) at evaluation' do
        expect(subject.evaluate(runtime)).to be_equal(subject.child)
      end

      it 'should accept quasiquotation' do
        # Case 1: child is idempotent with quasiquote
        expect(subject.quasiquote(runtime)).to be_equal(subject.child)

        # Case 2: quasiquoted child is different
        child = double('fake-child')
        expect(child).to receive(:quasiquote).with(runtime).and_return(integer(3))
        instance = SkmQuotation.new(child)
        expect(instance.child).to eq(child)
        quasi_result = instance.quasiquote(runtime)
        expect(quasi_result.child).to eq(3)
      end

      it 'should return its text representation' do
        txt1 = '<Skeem::SkmQuasiquotation: <Skeem::SkmString: foo>>'
        expect(subject.inspect).to eq(txt1)
      end
    end # context
  end # describe


  describe SkmUnquotation do
    include DatumDSL

    let(:sample_literal) { string('foo') }

    subject { SkmUnquotation.new(sample_literal) }

    context 'Initialization:' do
      it 'should be initialized with a Skeem element' do
        expect { SkmUnquotation.new(sample_literal) }.not_to raise_error
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      it 'should return the child(template) at evaluation' do
        expect(subject.evaluate(runtime)).to be_equal(subject.child)
      end

      it 'should accept quasiquotation' do
        # Case 1: child is idempotent with evaluate
        expect(subject.quasiquote(runtime)).to be_equal(subject.child)

        # Case 2: quasiquoted child is different
        child = double('fake-child')
        expect(child).to receive(:unquoted!)
        expect(child).to receive(:evaluate).with(runtime).and_return(integer(3))
        instance = SkmUnquotation.new(child)
        expect(instance.child).to eq(child)
        quasi_result = instance.quasiquote(runtime)
        expect(quasi_result).to eq(3)
      end

      it 'should return its text representation' do
        txt1 = '<Skeem::SkmUnquotation: <Skeem::SkmString: foo>>'
        expect(subject.inspect).to eq(txt1)
      end
    end # context
  end # describe

  describe SkmVariableReference do
    include DatumDSL

    let(:pos) { double('fake-position') }
    let(:sample_var) { identifier('three') }

    subject { SkmVariableReference.new(pos, sample_var) }

    context 'Initialization:' do
      it 'should be initialized with a position and a symbol' do
        expect { SkmVariableReference.new(pos, sample_var) }.not_to raise_error
      end

      it 'should know its variable' do
        expect(subject.variable).to be_equal(sample_var)
        expect(subject.variable).to be_equal(subject.child)
      end
    end # context

    context 'Provided services:' do
      let(:runtime) { Runtime.new(SkmFrame.new) }

      before(:each) do
        runtime.add_binding('three', integer(3))
      end

      it "should return the variable's value at evaluation" do
        expect(subject.evaluate(runtime)).to eq(3)
      end

      it 'should return itself at quasiquotation' do
        expect(subject.quasiquote(runtime)).to be_equal(subject)
      end

      it 'should return its text representation' do
        txt1 = '<Skeem::SkmVariableReference: <Skeem::SkmIdentifier: three>>'
        expect(subject.inspect).to eq(txt1)
      end
    end # context
  end # describe
end # module
