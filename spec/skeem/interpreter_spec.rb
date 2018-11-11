require 'stringio'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/interpreter' # Load the class under test

module Skeem
  describe Interpreter do
    include DatumDSL

    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Interpreter.new() }.not_to raise_error
      end

      it 'should have a parser' do
        expect(subject.parser).not_to be_nil
      end

      it 'should have a runtime object' do
        expect(subject.runtime).to be_kind_of(Runtime)
      end

      it 'should come with built-in functions' do
        expect(subject.runtime.environment).not_to be_empty
      end

      it 'should implement base bindings' do
        expect(subject.fetch('number?')).to be_kind_of(Primitive::PrimitiveProcedure)
        expect(subject.fetch('abs')).to be_kind_of(SkmDefinition)
        expect(subject.fetch('abs').expression).to be_kind_of(SkmLambda)
      end
    end # context

    context 'Interpreting self-evaluating expressions' do
      it 'should evaluate isolated booleans' do
        samples = [
        ['#f', false],
        ['#false', false],
        ['#t', true],
        ['#true', true]
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SkmBoolean)
          expect(result).to eq(predicted)
        end
      end

      it 'should evaluate isolated integers' do
        samples = [
          ['0', 0],
          ['3', 3],
          ['-3', -3],
          ['+12345', 12345],
          ['-12345', -12345]
        ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SkmInteger)
          expect(result).to eq(predicted)
        end
      end

      it 'should evaluate isolated real numbers' do
        samples = [
          ['0.0', 0.0],
          ['3.14', 3.14],
          ['-3.14', -3.14],
          ['+123e+45', 123e+45],
          ['-123e-45', -123e-45]
        ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SkmReal)
          expect(result).to eq(predicted)
        end
      end

      it 'should evaluate isolated strings' do
        samples = [
        ['"Hello, world"', 'Hello, world']
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SkmString)
          expect(result).to eq(predicted)
        end
      end

      it 'should evaluate vector of constants' do
        source = '#(2018 10 20 "Sat")'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmVector)
        predictions = [
          [SkmInteger, 2018],
          [SkmInteger, 10],
          [SkmInteger, 20],
          [SkmString, 'Sat']
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end
      end
    end # context

    context 'Built-in primitives' do
      it 'should implement variable definition' do
        result = subject.run('(define x 28)')
        expect(result).to be_kind_of(SkmDefinition)
      end

      it 'should implement variable reference' do
        source = <<-SKEEM
  ; Example from R7RS section 4.1.1
  (define x 28)
  x
SKEEM
        result = subject.run(source)
        end_result = result.last
        expect(end_result).to be_kind_of(SkmInteger)
        expect(end_result).to eq(28)
      end

      it 'should implement the simple conditional form' do
         checks = [
          ['(if (> 3 2) "yes")', 'yes'],
          ['(if (> 2 3) "yes")', :UNDEFINED]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the complete conditional form' do
        checks = [
          ['(if (> 3 2) "yes" "no")', 'yes'],
          ['(if (> 2 3) "yes" "no")', 'no']
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
        source = <<-SKEEM
  ; Example from R7RS section 4.1.5
  (if (> 3 2)
    (- 3 2)
    (+ 3 2))
SKEEM
        result = subject.run(source)
        expect(result).to eq(1)
      end

      it 'should implement the quotation of constant literals' do
         checks = [
          ['(quote a)', 'a'],
          ['(quote 145932)', 145932],
          ['(quote "abc")', 'abc'],
          ['(quote #t)', true],
          ["'a", 'a'],
          ["'145932", 145932],
          ["'\"abc\"", 'abc'],
          ["'#t", true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the quotation of vectors' do
        source = '(quote #(a b c))'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmVector)
        predictions = [
          [SkmIdentifier, 'a'],
          [SkmIdentifier, 'b'],
          [SkmIdentifier, 'c']
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end
      end

      it 'should implement the quotation of lists' do
        source = '(quote (+ 1 2))'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        predictions = [
          [SkmIdentifier, '+'],
          [SkmInteger, 1],
          [SkmInteger, 2]
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end

        source = "'()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        expect(result).to be_null
      end      

      it 'should implement the lambda function with one arg' do
        source = <<-SKEEM
  ; Simplified 'abs' function implementation
  (define abs
    (lambda (x)
      (if (< x 0) (- x) x)))
SKEEM
        subject.run(source)
        procedure = subject.fetch('abs').expression
        expect(procedure.arity).to eq(1)
        result = subject.run('(abs -3)')
        expect(result).to eq(3)
        result = subject.run('(abs 0)')
        expect(result).to eq(0)
        result = subject.run('(abs 3)')
        expect(result).to eq(3)
      end

      it 'should implement the lambda function with two args' do
        source = <<-SKEEM
  ; Simplified 'min' function implementation
  (define min
    (lambda (x y)
      (if (< x y) x y)))
SKEEM
        subject.run(source)
        procedure = subject.fetch('min').expression
        expect(procedure.arity).to eq(2)
        result = subject.run('(min 1 2)')
        expect(result).to eq(1)
        result = subject.run('(min 2 1)')
        expect(result).to eq(1)
        result = subject.run('(min 2 2)')
        expect(result).to eq(2)
      end

      it 'should implement recursive functions' do
        source = <<-SKEEM
  ; Example from R7RS section 4.1.5
  (define fact (lambda (n)
    (if (<= n 1)
      1
      (* n (fact (- n 1))))))
  (fact 10)
SKEEM
        result = subject.run(source)
        expect(result.last.value).to eq(3628800)
      end

      it 'should accept calls to anonymous procedures' do
        source = '((lambda (x) (+ x x)) 4)'
        result = subject.run(source)
        expect(result).to eq(8)
      end

      it 'should support procedures with variable number of arguments' do
        # Example from R7RS section 4.1.4
        source = '((lambda x x) 3 4 5 6)'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        expect(result.length).to eq(4)
      end

      it 'should support procedures with dotted pair arguments' do
        # Example from R7RS section 4.1.4
        source = '((lambda (x y . z) z) 3 4 5 6)'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        expect(result.length).to eq(2)
        expect(result.head).to eq(5)
        expect(result.last).to eq(6)
      end

      it 'should implement the compact define + lambda syntax' do
          source = <<-SKEEM
  ; Alternative syntax to: (define f (lambda x (+ x 42)))
  (define (f x)
    (+ x 42))
  (f 23)
SKEEM
          result = subject.run(source)
          expect(result.last.value).to eq(65)
      end

      it 'should implement the compact define + pair syntax' do
          source = <<-SKEEM
  ; Alternative syntax to: (define nlist (lambda args args))
  (define (nlist . args)
  args)
  (nlist 0 1 2 3 4)
SKEEM
          result = subject.run(source)
          expect(result.last.last.value).to eq(4)
      end
    end # context

    context 'Quasiquotation:' do
      it 'should implement the quasiquotation of constant literals' do
         checks = [
          ['(quasiquote a)', 'a'],
          ['(quasiquote 145932)', 145932],
          ['(quasiquote "abc")', 'abc'],
          ['(quasiquote #t)', true],
          ['`a', 'a'],
          ['`145932', 145932],
          ['`"abc"', 'abc'],
          ['`#t', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the quasiquotation of vectors' do
        source = '(quasiquote #(a b c))'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmVector)
        predictions = [
          [SkmIdentifier, 'a'],
          [SkmIdentifier, 'b'],
          [SkmIdentifier, 'c']
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end
      end
      
      it 'should implement the unquote of vectors' do
        source = '`#( ,(+ 1 2) 4)'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmVector)
        predictions = [
          [SkmInteger, 3],
          [SkmInteger, 4]
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end

        source = "`#()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmVector)
        expect(result).to be_empty
        
        # Nested vectors
        source = '`#(a b #(,(+ 2 3) c) d)'
        result = subject.run(source)
        # expected: #(a b #(5 c) d)
        expect(result).to be_kind_of(SkmVector)
        predictions = [
          [SkmIdentifier, 'a'],
          [SkmIdentifier, 'b'],
          [SkmVector, vector([integer(5), identifier('c')])],
          [SkmIdentifier, 'd']
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end        
      end      
            
      it 'should implement the quasiquotation of lists' do
        source = '(quasiquote (+ 1 2))'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        predictions = [
          [SkmIdentifier, '+'],
          [SkmInteger, 1],
          [SkmInteger, 2]
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end

        source = "`()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        expect(result).to be_null
      end
      
      it 'should implement the unquote of lists' do
        source = '`(list ,(+ 1 2) 4)'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        predictions = [
          [SkmIdentifier, 'list'],
          [SkmInteger, 3],
          [SkmInteger, 4]
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end

        source = "`()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmList)
        expect(result).to be_null
        
        # nested lists
        source = '`(a b (,(+ 2 3) c) d)'
        result = subject.run(source)
        # expected: (a b (5 c) d)
        expect(result).to be_kind_of(SkmList)
        predictions = [
          [SkmIdentifier, 'a'],
          [SkmIdentifier, 'b'],
          [SkmList, list([integer(5), identifier('c')])],
          [SkmIdentifier, 'd']
        ]
        predictions.each_with_index do |(type, value), index|
          expect(result.members[index]).to be_kind_of(type)
          expect(result.members[index]).to eq(value)
        end        
      end
=begin
`(+ 2 ,(* 3 4))  (+ 2 12)
`(a b ,(reverse '(c d e)) f g)  (a b (e d c) f g)
(let ([a 1] [b 2])
  `(,a . ,b))  (1 . 2) 

`(+ ,@(cdr '(* 2 3)))  (+ 2 3)
`(a b ,@(reverse '(c d e)) f g)  (a b e d c f g)
(let ([a 1] [b 2])
  `(,a ,@b))  (1 . 2)
`#(,@(list 1 2 3))  #(1 2 3) 

'`,(cons 'a 'b)  `,(cons 'a 'b)
`',(cons 'a 'b)  '(a . b) 
=end
    end # context

    context 'Built-in primitive procedures' do
      it 'should implement the division of numbers' do
        result = subject.run('(/ 24 3)')
        expect(result).to be_kind_of(SkmInteger)
        expect(result).to eq(8)
      end

      it 'should handle arithmetic expressions' do
        result = subject.run('(+ (* 2 100) (* 1 10))')
        expect(result).to be_kind_of(SkmInteger)
        expect(result).to eq(210)
      end
    end # context

    context 'Built-in standard procedures' do
      it 'should implement the zero? predicate' do
        checks = [
          ['(zero? 3.1)', false],
          ['(zero? -3.1)', false],
          ['(zero? 0)', true],
          ['(zero? 0.0)', true],
          ['(zero? 3)', false],
          ['(zero? -3)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the positive? predicate' do
        checks = [
          ['(positive? 3.1)', true],
          ['(positive? -3.1)', false],
          ['(positive? 0)', true],
          ['(positive? 0.0)', true],
          ['(positive? 3)', true],
          ['(positive? -3)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the positive? predicate' do
        checks = [
          ['(positive? 3.1)', true],
          ['(positive? -3.1)', false],
          ['(positive? 0)', true],
          ['(positive? 0.0)', true],
          ['(positive? 3)', true],
          ['(positive? -3)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the negative? predicate' do
        checks = [
          ['(negative? 3.1)', false],
          ['(negative? -3.1)', true],
          ['(negative? 0)', false],
          ['(negative? 0.0)', false],
          ['(negative? 3)', false],
          ['(negative? -3)', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the even? predicate' do
        checks = [
          ['(even? 0)', true],
          ['(even? 1)', false],
          ['(even? 2.0)', true],
          ['(even? -120762398465)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the odd? predicate' do
        checks = [
          ['(odd? 0)', false],
          ['(odd? 1)', true],
          ['(odd? 2.0)', false],
          ['(odd? -120762398465)', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the abs function' do
        checks = [
          ['(abs 3.1)', 3.1],
          ['(abs -3.1)', 3.1],
          ['(abs 0)', 0],
          ['(abs 0.0)', 0],
          ['(abs 3)', 3],
          ['(abs -7)', 7]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end

      it 'should implement the square function' do
        checks = [
          ['(square 42)', 1764],
          ['(square 2.0)', 4.0],
          ['(square -7)', 49]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end
      
      it 'should implement the symbol=? procedure' do
        checks = [
          ["(symbol=? 'a 'a)", true],
          ["(symbol=? 'a (string->symbol \"a\"))", true],
          ["(symbol=? 'a 'b)", false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result).to eq(expectation)
        end
      end       

      it 'should implement the list procedure' do
        checks = [
          ['(list)', []],
          ['(list 1)', [1]],
          ['(list 1 2 3 4)', [1, 2, 3, 4]]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.members).to eq(expectation)
        end
      end
    end # context
  end # describe
end # module