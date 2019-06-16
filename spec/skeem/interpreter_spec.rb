require 'stringio'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/datum_dsl'
require_relative '../../lib/skeem/interpreter' # Load the class under test

module Skeem
  describe Interpreter do
    include InterpreterSpec
    include DatumDSL

    context 'Initialization:' do
      it 'could be initialized without an argument' do
        expect { Interpreter.new }.not_to raise_error
      end

      it 'could be initialized with a block argument' do
        expect { Interpreter.new { |interp| }  }.not_to raise_error
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
        expect(subject.fetch('abs')).to be_kind_of(SkmLambda)
        expect(subject.fetch('abs').formals.arity).to eq(1)
        expect(subject.fetch('abs').formals.formals[0]).to eq('x')
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
        compare_to_predicted(samples) do |result, predicted|
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
        compare_to_predicted(samples) do |result, predicted|
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
        compare_to_predicted(samples) do |result, predicted|
          expect(result).to be_kind_of(SkmReal)
          expect(result).to eq(predicted)
        end
      end

      it 'should evaluate isolated strings' do
        samples = [
          ['"Hello, world"', 'Hello, world']
        ]
        compare_to_predicted(samples) do |result, predicted|
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
        expect(subject.fetch('x')).to eq(28)
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
          ['(if (> 2 3) "yes")', SkmUndefined.instance]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the complete conditional form' do
        checks = [
          ['(if (> 3 2) "yes" "no")', 'yes'],
          ['(if (> 2 3) "yes" "no")', 'no']
        ]
        compare_to_predicted(checks)
        source = <<-SKEEM
  ; Example from R7RS section 4.1.5
  (if (> 3 2)
    (- 3 2)
    (+ 3 2))
SKEEM
        result = subject.run(source)
        expect(result).to eq(1)
      end

      it 'should implement the cond form' do
        source = <<-SKEEM
  (define signum (lambda (x)
    (cond
      ((> x 0) 1)
      ((= x 0) 0)
      ((< x 0) -1)
    )))
SKEEM
        result = subject.run(source)
        checks = [
          ['(signum 3)', 1],
          ['(signum 0)', 0],
          ['(signum -3)', -1]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the cond form with arrows' do
        source = <<-SKEEM
  (define signum (lambda (x)
    (cond
      ((> x 0) => 1)
      ((= x 0) => 0)
      ((< x 0) => -1)
    )))
SKEEM
        result = subject.run(source)
        checks = [
          ['(signum 3)', 1],
          ['(signum 0)', 0],
          ['(signum -3)', -1]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the cond ... else form' do
        source = <<-SKEEM
  (define signum (lambda (x)
    (cond
      ((> x 0) 1)
      ((= x 0) 0)
      (else -1)
    )))
SKEEM
        result = subject.run(source)
        checks = [
          ['(signum 3)', 1],
          ['(signum 0)', 0],
          ['(signum -3)', -1]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the truncate procedure' do
        checks = [
          ['(truncate -4.3)', -4],
          ['(truncate 3.5)', 3]
        ]
        compare_to_predicted(checks)
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
        compare_to_predicted(checks)
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
        expect(result).to be_kind_of(SkmPair)
        predictions = [
          [SkmIdentifier, '+'],
          [SkmInteger, 1],
          [SkmInteger, 2]
        ]
        members = result.to_a
        predictions.each_with_index do |(type, value), index|
          expect(members[index]).to be_kind_of(type)
          expect(members[index]).to eq(value)
        end

        source = "'()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmEmptyList)
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
        procedure = subject.fetch('abs')
        expect(procedure.arity).to eq(1)
        checks = [
          ['(abs -3)', 3],
          ['(abs 0)', 0],
          ['(abs 3)', 3]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the lambda function with two args' do
        source = <<-SKEEM
  ; Simplified 'min' function implementation
  (define min
    (lambda (x y)
      (if (< x y) x y)))
SKEEM
        subject.run(source)
        procedure = subject.fetch('min')
        expect(procedure.arity).to eq(2)
        checks = [
          ['(min 1 2)', 1],
          ['(min 2 1)', 1],
          ['(min 2 2)', 2]
        ]
        compare_to_predicted(checks)
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
        expect(result).to be_kind_of(SkmPair)
        expect(result.length).to eq(4)
      end

      it 'should support procedures with dotted pair arguments' do
        # Example from R7RS section 4.1.4
        source = '((lambda (x y . z) z) 3 4 5 6)'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmPair)
        expect(result.length).to eq(2)
        expect(result.first).to eq(5)
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

      it 'should support the nested define construct' do
        source = <<-SKEEM
  (define (quadruple x)
    (define (double x) ; define a local procedure double
      (+ x x))
    (double (double x))) ; nested calls to the local procedure

  (quadruple 5) ; => 20
SKEEM
        result = subject.run(source)
        expect(result.last.value).to eq(20)
      end


    end # context

    context 'Binding constructs:' do
      it 'should implement local bindings' do
        source = <<-SKEEM
  (let ((x 2)
        (y 3))
    (* x y))
SKEEM
        result = subject.run(source)
        expect(result).to eq(6)
      end

      it 'should implement precedence of local bindings' do
        source = <<-SKEEM
  (define x 23)
  (define y 42)

  ; local variable y in let block "shadows" the global one
  (let ((y 43))
    (+ x y))
SKEEM
        result = subject.run(source)
        expect(result.last).to eq(66)
      end

      it 'should support the nesting of local bindings' do
        source = <<-SKEEM
  (let ((x 2) (y 3))
  (let ((x 7)
    (z (+ x y)))
  (* z x)))
SKEEM
        expect_expr(source).to eq(35)
      end

      it 'should support the nesting of a lambda in a let expression' do
        source =<<-SKEEM
  (define make-counter
    (lambda ()
       (let ((count 0))
          (lambda ()
             (set! count (+ count 1))
             count))))

  (define c1 (make-counter))
  (define c2 (make-counter))
  (c1)
  (c2)
  (c1)
  (c2)
  (c1)
SKEEM
        result = subject.run(source)
        expect(result.last).to eq(3)
      end

      it 'should implement let* expression' do
        source = <<-SKEEM
  (let ((x 2) (y 3))
    (let* ((x 7)
      (z (+ x y)))
      (* z x)))
SKEEM
        expect_expr(source).to eq(70)
      end
    end # context

    context 'Sequencing constructs:' do
      it 'should implement begin as a sequence of expressions' do
        source = <<-SKEEM
  (define x 0)
  (and (= x 0)
    (begin (set! x 5)
      (+ x 1))) ; => 6
SKEEM
        result = subject.run(source)
        expect(result.last).to eq(6)
      end

      it 'should implement begin as a sequence of expressions' do
        source = <<-SKEEM
  (let ()
    (begin (define x 3) (define y 4))
    (+ x y))  ; => 7
SKEEM
        result = subject.run(source)
        expect(result).to eq(7)
      end

      it 'should support begin as lambda body' do
        source = <<-SKEEM
  (define kube (lambda (x)
    (begin
      (define z x)
      (* z z z)
    )
  ))
  (kube 3)
  (kube 4)
SKEEM
        result = subject.run(source)
        expect(result.last).to eq(64)
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
        compare_to_predicted(checks)
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
        expect(result).to be_kind_of(SkmPair)
        predictions = [
          [SkmIdentifier, '+'],
          [SkmInteger, 1],
          [SkmInteger, 2]
        ]
        predictions.each do |(type, value)|
          expect(result.car).to be_kind_of(type)
          expect(result.car).to eq(value)
          result = result.cdr
        end

        source = "`()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmEmptyList)
        expect(result).to be_null
      end

      it 'should implement the unquote of lists' do
        source = '`(list ,(+ 1 2) 4)'
        result = subject.run(source)
        expect(result).to be_kind_of(SkmPair)
        predictions = [
          [SkmIdentifier, 'list'],
          [SkmInteger, 3],
          [SkmInteger, 4]
        ]
        predictions.each do |(type, value)|
          expect(result.car).to be_kind_of(type)
          expect(result.car).to eq(value)
          result = result.cdr
        end

        source = "`()"
        result = subject.run(source)
        expect(result).to be_kind_of(SkmEmptyList)
        expect(result).to be_null

        # nested lists
        source = '`(a b (,(+ 2 3) c) d)'
        result = subject.run(source)
        # expected: (a b (5 c) d)
        expect(result).to be_kind_of(SkmPair)
        predictions = [
          [SkmIdentifier, 'a'],
          [SkmIdentifier, 'b'],
          [SkmPair, list([integer(5), identifier('c')])],
          [SkmIdentifier, 'd']
        ]
        predictions.each do |(type, value)|
          expect(result.car).to be_kind_of(type)
          expect(result.car).to eq(value)
          result = result.cdr
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
        compare_to_predicted(checks)
      end

      it 'should implement the positive? predicate' do
        checks = [
          ['(positive? 3.1)', true],
          ['(positive? -3.1)', false],
          ['(positive? 0)', false],
          ['(positive? 0.0)', false],
          ['(positive? 3)', true],
          ['(positive? -3)', false]
        ]
        compare_to_predicted(checks)
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
        compare_to_predicted(checks)
      end

      it 'should implement the even? predicate' do
        checks = [
          ['(even? 0)', true],
          ['(even? 1)', false],
          ['(even? 2.0)', true],
          ['(even? -120762398465)', false]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the odd? predicate' do
        checks = [
          ['(odd? 0)', false],
          ['(odd? 1)', true],
          ['(odd? 2.0)', false],
          ['(odd? -120762398465)', true]
        ]
        compare_to_predicted(checks)
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
        compare_to_predicted(checks)
      end

      it 'should implement the square function' do
        checks = [
          ['(square 42)', 1764],
          ['(square 2.0)', 4.0],
          ['(square -7)', 49]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the not procedure' do
        checks = [
          ['(not #t)', false],
          ['(not 3)', false],
          ['(not (list 3))', false],
          ['(not #f)', true],
          ["(not '())", false],
          ['(not (list))', false],
          ["(not 'nil)", false]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the list procedure' do
        checks = [
          ['(list)', []],
          ['(list 1)', [1]],
          ['(list 1 2 3 4)', [1, 2, 3, 4]],
          ["(list 'a (+ 3 4) 'c)", [identifier('a'), 7, identifier('c')]]
        ]
        compare_to_predicted(checks) do |result, expectation|
          expect(result.to_a).to eq(expectation)
        end
      end

      it 'should implement the caar procedure' do
        checks = [
          ["(caar '((a)))", 'a'],
          ["(caar '((1 2) 3 4))", 1]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the cadr procedure' do
        checks = [
          ["(cadr '(a b c))", 'b'],
          ["(cadr '((1 2) 3 4))", 3]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the cdar procedure' do
        checks = [
          ["(cdar '((7 6 5 4 3 2 1) 8 9))", [6, 5, 4, 3, 2, 1]]
        ]
        compare_to_predicted(checks) do |result, expectation|
          expect(result.to_a).to eq(expectation)
        end
      end

      it 'should implement the cddr procedure' do
        checks = [
          ["(cddr '(2 1))", []]
        ]
        compare_to_predicted(checks) do |result, expectation|
          expect(result.to_a).to eq(expectation)
        end
      end

      it 'should implement the symbol=? procedure' do
        checks = [
          ["(symbol=? 'a 'a)", true],
          ["(symbol=? 'a (string->symbol \"a\"))", true],
          ["(symbol=? 'a 'b)", false]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the floor-quotient procedure' do
        checks = [
          ['(floor-quotient 5 2)', 2],
          ['(floor-quotient -5 2)', -3],
          ['(floor-quotient 5 -2)', -3],
          ['(floor-quotient -5 -2)', 2]
        ]
        compare_to_predicted(checks)
      end

      it 'should implement the floor-remainder (modulo) procedure' do
        checks = [
          ['(floor-remainder 16 4)', 0],
          ['(floor-remainder 5 2)', 1],
          ['(floor-remainder -45.0 7)', 4.0],
          ['(floor-remainder 10.0 -3.0)', -2.0],
          ['(floor-remainder -17 -9)', -8],
          ['(modulo 16 4)', 0],
          ['(modulo 5 2)', 1],
          ['(modulo -45.0 7)', 4.0],
          ['(modulo 10.0 -3.0)', -2.0],
          ['(modulo -17 -9)', -8]
        ]
        compare_to_predicted(checks)
      end

        it 'should implement the truncate-quotient procedure' do
          checks = [
            ['(truncate-quotient 5 2)', 2],
            ['(truncate-quotient -5 2)', -2],
            ['(truncate-quotient 5 -2)', -2],
            ['(truncate-quotient -5 -2)', 2],
            ['(quotient 5 2)', 2],
            ['(quotient -5 2)', -2],
            ['(quotient 5 -2)', -2],
            ['(quotient -5 -2)', 2]
          ]
          compare_to_predicted(checks)
        end

        it 'should implement the truncate-remainder procedure' do
          checks = [
            ['(truncate-remainder 5 2)', 1],
            ['(truncate-remainder -5 2)', -1],
            ['(truncate-remainder 5 -2)', 1],
            ['(truncate-remainder -5 -2)', -1],
            ['(remainder 5 2)', 1],
            ['(remainder -5 2)', -1],
            ['(remainder 5 -2)', 1],
            ['(remainder -5 -2)', -1]
          ]
          compare_to_predicted(checks)
        end

      it 'should implement the test-equal procedure' do
        checks = [
          ["(test-equal (cons 1 2) (cons 1 2))", true]
        ]
        compare_to_predicted(checks)
      end
    end # context

    context 'Second-order functions' do
      it 'should implement lambda that calls second-order function' do
        source = <<-SKEEM
  (define twice
    (lambda (x)
      (* 2 x)))
  (define compose
    (lambda (f g)
      (lambda (x)
        (f (g x)))))
  (define repeat
    (lambda (f)
      (compose f f)))
  ((repeat twice) 5)
SKEEM
        result = subject.run(source)
        expect(result.last).to eq(20)
      end

      it 'should implement the composition of second-order functions' do
        source = <<-SKEEM
  (define twice
    (lambda (x)
      (* 2 x)))
  (define compose
    (lambda (f g)
      (lambda (x)
        (f (g x)))))
  (define repeat
    (lambda (f)
      (compose f f)))
  ((repeat (repeat twice)) 5)
SKEEM
        result = subject.run(source)
        expect(result.last).to eq(80)
      end
    end # context
  end # describe
end # module