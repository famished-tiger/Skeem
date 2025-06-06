# frozen_string_literal: true

require_relative '../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../lib/skeem/interpreter'

module Skeem
  describe 'The interpreter and compound procedures' do
    subject(:interpreter) do
      # We load the interpreter with the primitive procedures only
      Interpreter.new { |interp| interp.add_primitives(interp.runtime) }
    end

    let(:definition_set) do
      source = <<-SKEEM
  (define square
    (lambda (x)
      (* x x)))

  (define sum-of-squares
    (lambda (x y)
      (+ (square x) (square y))))

  (define f
    (lambda (a)
      (sum-of-squares (+ a 1) (* a 2))))
SKEEM
      source
    end

    context 'Defining compound procedures:' do
      it 'accepts the definition of simple procedure with arity 1' do
        source = "#{definition_set}\nsquare"
        result = interpreter.run(source)

        square = result.last
        expect(square).to be_a(SkmLambda)
        expect(square.arity).to eq(1)
        expect(square.environment).to eq(interpreter.runtime.environment)
      end

      it 'accepts the definition of simple procedure with arity 2' do
        source = "#{definition_set}\nsum-of-squares"
        result = interpreter.run(source)

        square = result.last
        expect(square).to be_a(SkmLambda)
        expect(square.arity).to eq(2)
        expect(square.environment).to eq(interpreter.runtime.environment)
      end
    end # context

    context 'Calling compound procedures:' do
      it 'supports the call to a simple procedure with arity 1' do
        # Case 1: argument is a simple datum
        interpreter.run(definition_set)
        result = interpreter.run('(square 2)')
        expect(result).to eq(4)

        # Case 2: argument is a sub-expression
        ptree = interpreter.parse('(square (+ 2 1))')
        proc_call = ptree.root
        expect(proc_call.evaluate(interpreter.runtime)).to eq(9)
      end

      it 'supports the call to a simple procedure with arity 2' do
        source = "#{definition_set}\n(sum-of-squares 3 4)"
        result = interpreter.run(source)

        expect(result.last).to eq(25)
      end

      it 'supports the call to a nested lambda procedure' do
        source = "#{definition_set}\n(f 5)"
        result = interpreter.run(source)

        expect(result.last).to eq(136)
      end

      it 'accepts calls to anonymous procedures' do
        source = '((lambda (x) (+ x x)) 4)'
        result = interpreter.run(source)
        expect(result).to eq(8)
      end

      it 'accepts unary second-order lambdas' do
        source = <<-SKEEM
  (define add-with
    (lambda (x) (lambda (y) (+ x y)))
  )
  (define add4 (add-with 4))
SKEEM
        interpreter.run(source)
        result = interpreter.run('(add4 3)')
        expect(result).to eq(7)
      end
    end # context

    context 'More advanced features:' do
      subject(:interpreter) { Interpreter.new }

      it 'implements binary second-order functions' do
        source = <<-SKEEM
  (define compose
    (lambda (f g)
      (lambda (x)
        (f (g x)))))
SKEEM
        interpreter.run(source)
        result = interpreter.run('((compose list square) 5)')
        expect(result.last).to eq(25)
      end
    end # context
  end # describe
end # module
