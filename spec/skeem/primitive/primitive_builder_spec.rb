# frozen_string_literal: true

require_relative '../../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../../lib/skeem/interpreter'

module Skeem
  module Primitive
    describe 'Testing primitive procedures' do
      include InterpreterSpec

      subject(:builder) do
        # We load the interpreter with the primitive procedures only
        Interpreter.new { |interp| interp.add_primitives(interp.runtime) }
      end

      def array2list_ids(arr)
        arr.map { |elem| SkmIdentifier.create(elem) }
      end

      context 'Arithmetic operators:' do
        it 'implements the set! form' do
          skeem1 = <<-SKEEM
  (define x 2)
  (+ x 1)
SKEEM
          result = builder.run(skeem1)
          expect(result.last).to eq(3)  # x is bound to value 2

          skeem2 = <<-SKEEM
  (set! x 4)
  (+ x 1)
SKEEM
          result = builder.run(skeem2)
          expect(result.last).to eq(5)  # x is now bound to value 4
        end
      end # context

      context 'Arithmetic operators:' do
        it 'implements the addition operator' do
          checks = [
            ['(+)', 0], # '+' as nullary operator. Example from section 6.2.6
            ['(+ -3)', -3], # '+' as unary operator
            ['(+ 3 4)', 7], # '+' as binary operator. Example from section 4.1.3
            ['(+ 1/2 2/3)', Rational(7, 6)],
            ['(+ 1/2 3)', Rational(7, 2)],
            ['(+ 2 2.34)', 4.34]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the minus operator' do
          checks = [
            ['(- 3)', -3], # '-' as unary operator (= sign change)
            ['(- -2/3)', Rational(2, 3)],
            ['(- 3 4)', -1], # '-' as binary operator. Example from section 6.2.6
            ['(- 3 4 5)', -6] # '-' as variadic operator. Example from section 6.2.6
          ]
          compare_to_predicted(checks)
        end

        it 'implements the product operator' do
          checks = [
            ['(*)', 1], # '*' as nullary operator. Example from section 6.2.6
            ['(* 4)', 4], # '*' as unary operator. Example from section 6.2.6
            ['(* 5 8)', 40], # '*' as binary operator.
            ['(* 2/3 5/7)', Rational(10, 21)],
            ['(* 2 3 4 5)', 120] # '*' as variadic operator.
          ]
          compare_to_predicted(checks)
        end

        it 'implements the division operator' do
          checks = [
            ['(/ 3)', Rational(1, 3)], # '/' as unary operator (= inverse of argument)
            ['(/ 3/4)', Rational(4, 3)],
            ['(/ 3 4)', Rational(3, 4)], # '/' as binary operator.
            ['(/ 2/3 5/7)', Rational(14, 15)],
            ['(/ 3 4 5)', Rational(3, 20)] # '/' as variadic operator. Example from section 6.2.6
          ]
          compare_to_predicted(checks)

          result = builder.run('(/ 3 4.5)')
          expect(result.value).to be_within(0.000001).of(0.66666667)
        end

        it 'implements the floor/ procedure' do
          checks = [
            ['(floor/ 5 2)', [2, 1]], # Binary procedure.
            ['(floor/ -5 2)', [-3, 1]],
            ['(floor/ 5 -2)', [-3, -1]],
            ['(floor/ -5 -2)', [2, -1]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect([result.car, result.cdr]).to eq(expectation)
          end
        end

        it 'implements the truncate/ procedure' do
          checks = [
            ['(truncate/ 5 2)', [2, 1]], # Binary procedure.
            ['(truncate/ -5 2)', [-2, -1]],
            ['(truncate/ 5 -2)', [-2, 1]],
            ['(truncate/ -5 -2)', [2, -1]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect([result.car, result.cdr]).to eq(expectation)
          end
        end

        it 'implements the gcd procedure' do
          checks = [
            ['(gcd)', 0],
            ['(gcd 47)', 47],
            ['(gcd 7 11)', 1],
            ['(gcd 32 -36)', 4],
            ['(gcd 32 -36 25)', 1]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the lcm procedure' do
          checks = [
            ['(lcm)', 1],
            ['(lcm 47)', 47],
            ['(lcm 7 11)', 77],
            ['(lcm 32 -36)', 288],
            ['(lcm 32 -36 10)', 1440],
            ['(lcm 32.0 -36)', 288]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the numerator procedure' do
          checks = [
            ['(numerator (/ 6 4))', 3]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the denominator procedure' do
          checks = [
            ['(denominator (/ 6 4))', 2]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the floor procedure' do
          checks = [
            ['(floor -4.3)', -5],
            ['(floor 3.5)', 3]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the ceiling procedure' do
          checks = [
            ['(ceiling -4.3)', -4],
            ['(ceiling 3.5)', 4]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the round procedure' do
          checks = [
            ['(round -4.3)', -4],
            ['(round 3.5)', 4],
            ['(round 7/2)', 4],
            ['(round 7)', 7]
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'Comparison operators' do
        it 'implements the eqv? procedure' do
          checks = [
            ['(eqv? #f #f)', true],
            ['(eqv? #t #t)', true],
            ['(eqv? #f #t)', false],
            ["(eqv? 'a 'a)", true],
            ["(eqv? 'a 'b)", false],
            ['(eqv? 2 2)', true],
            ['(eqv? 2 2.0)', true],
            ['(eqv? 3 2)', false],
            ["(eqv? '() '())", true],
            ['(eqv? 100000000 100000000)', true],
            ['(eqv? "a" "a")', false],
            ['(eqv? "a" "b")', false],
            ['(eqv? (cons 1 2) (cons 1 2))', false],
            ['(eqv? (lambda () 1) (lambda () 2))', false],
            ['(define p (lambda (x) x)) (eqv? p p)', true],
            ["(eqv? #f 'nil)", false]
          ]
          compare_to_predicted(checks) do |result, expectation|
            if result.length > 1
              expect(result.last).to eq(expectation)
            else
              expect(result).to eq(expectation)
            end
          end
        end

        it 'implements the equal? procedure' do
          checks = [
            ['(equal? #f #f)', true],
            ['(equal? #t #t)', true],
            ['(equal? #f #t)', false],
            ["(equal? 'a 'a)", true],
            ["(equal? 'a 'b)", false],
            ["(equal? '(a) '(a))", true],
            ["(equal? '(a) '(b))", false],
            ["(equal? '(a (b) c) '(a (b) c))", true],
            ["(equal? (cdr '(a)) '())", true],
            ['(equal? "abc" "abc")', true],
            ['(equal? "abc" "acb")', false],
            ['(equal? 2 2)', true],
            ["(equal? '#(a) '#(b))", false],
            ["(equal? '#(a) '#(a))", true],
            ["(equal? (make-vector 5 'a) (make-vector 5 'a))", true],
            ['(equal? car car)', true],
            ['(equal? car cdr)', false],
            ['(equal? (lambda (x) x) (lambda (y) y))', false]
          ]
          compare_to_predicted(checks) do |result, expectation|
            if result.length > 1
              expect(result.last).to eq(expectation)
            else
              expect(result).to eq(expectation)
            end
          end
        end

        it 'implements the equality operator' do
          checks = [
            ['(= 3)', true], # '=' as unary operator
            ['(= 3 3)', true], # '=' as binary operator
            ['(= 3 (+ 1 2) (- 4 1))', true], # '=' as variadic operator
            ['(= "foo" "foo")', true],
            ['(= 3 4)', false],
            ['(= "foo" "bar")', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the less than operator' do
          checks = [
            ['(< 3)', false], # '<' as unary operator
            ['(< 3 4)', true], # '<' as binary operator
            ['(< 3 (+ 2 2) (+ 4 1))', true], # '<' as variadic operator
            ['(< 3 3)', false],
            ['(< 3 2)', false],
            ['(< 3 4 5 4)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the greater than operator' do
          checks = [
            ['(> 3)', false], # '>' as unary operator
            ['(> 3 2)', true], # '>' as binary operator
            ['(> 3 (- 4 2) (- 2 1))', true], # '>' as variadic operator
            ['(> 3 3)', false],
            ['(> 3 4)', false],
            ['(> 3 2 1 2)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the less or equal than operator' do
          checks = [
            ['(<= 3)', true], # '<=' as unary operator
            ['(<= 3 4)', true], # '<=' as binary operator
            ['(<= 3 (+ 2 2) (+ 4 1))', true], # '<=' as variadic operator
            ['(<= 3 3)', true],
            ['(<= 3 2)', false],
            ['(<= 3 4 5 4)', false],
            ['(<= 3 4 5 5)', true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the greater or equal than operator' do
          checks = [
            ['(>= 3)', true], # '>=' as unary operator
            ['(>= 3 2)', true],
            ['(>= 3 (- 4 2) (- 2 1))', true],
            ['(>= 3 3)', true],
            ['(>= 3 4)', false],
            ['(>= 3 2 1 2)', false],
            ['(>= 3 2 1 1)', true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the max procedure' do
          checks = [
            ['(max 3 4)', 4],
            ['(max 3.9 4)', 4],
            ['(max 4 -7 2 0 -6)', 4]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the min procedure' do
          checks = [
            ['(min 3 4)', 3],
            ['(min 3.9 4)', 3.9],
            ['(min 4 -7 2 0 -6)', -7]
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'Number procedures:' do
        it 'implements the number? predicate' do
          checks = [
            ['(number? 3.1)', true],
            ['(number? 22/7)', true],
            ['(number? 3)', true],
            ['(number? "3")', false],
            ['(number? #t)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the real? predicate' do
          checks = [
            ['(real? 3.1)', true],
            ['(real? 22/7)', true],
            ['(real? 3)', true],
            ['(real? "3")', false],
            ['(real? #t)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the rational? predicate' do
          checks = [
            ['(rational? 3.1)', false],
            ['(rational? 3.0)', true],
            ['(rational? 22/7)', true],
            ['(rational? 3)', true],
            ['(rational? "3")', false],
            ['(rational? #t)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the integer? predicate' do
          checks = [
            ['(integer? 3.1)', false],
            ['(integer? 3.0)', true],
            ['(integer? 22/7)', false],
            ['(integer? 3)', true],
            ['(integer? "3")', false],
            ['(integer? #t)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the number->string procedure' do
          checks = [
            ['(number->string 3.4)', '3.4'],
            ['(number->string 22/7)', '22/7'],
            ['(number->string 1e2)', '100.0'],
            ['(number->string 1e-23)', '1.0e-23'],
            ['(number->string -7)', '-7']
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'Boolean procedures:' do
        it 'implements the and procedure' do
          checks = [
            ['(and (= 2 2) (> 2 1))', true],
            ['(and (= 2 2) (< 2 1))', false],
            ['(and)', true]
          ]
          compare_to_predicted(checks)

          # If all the expressions evaluate to true values,
          # the values of the last expression are returned.
          source = "(and 1 2 'c '(f g))"
          result = builder.run(source)
          expect(result).to be_a(SkmPair)
          expect(result.car).to eq('f')
          expect(result.cdr).to be_a(SkmPair)
          expect(result.cdr.car).to eq('g')
        end

        it 'implements the or procedure' do
          checks = [
            ['(or (= 2 2) (> 2 1))', true],
            ['(or (= 2 2) (< 2 1))', true],
            ['(or)', false],
            ['(or #f)', false],
            ['(or #f #t)', true],
            ['(or #f #f #f)', false]

          ]
          compare_to_predicted(checks)

          # When an expression evaluates to true value,
          # the values of the this expression is returned.
          source = "(or #f 'a #f)"
          result = builder.run(source)
          expect(result).to be_a(SkmIdentifier)
          expect(result).to eq('a')
        end

        it 'implements the boolean? procedure' do
          checks = [
            ['(boolean? #f)', true],
            ['(boolean? 0)', false],
            ["(boolean? '())", false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the boolean=? procedure' do
          checks = [
            ['(boolean=? #t #t)', true],
            ['(boolean=? #f #f)', true],
            ['(boolean=? #t #f)', false],
            ['(boolean=? #f #t)', false]
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'String procedures:' do
        it 'implements the string? procedure' do
          checks = [
            ['(string? #f)', false],
            ['(string? 3)', false],
            ['(string? "hi")', true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the string->symbol procedure' do
          checks = [
            ['(string->symbol "mISSISSIppi")', 'mISSISSIppi']
          ]
          checks.each do |(skeem_expr, expectation)|
            result = builder.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end

        it 'implements the string=? procedure' do
          checks = [
            ['(string=? "Mom" "Mom")', true],
            ['(string=? "Mom" "Mum")', false],
            ['(string=? "Mom" "Dad")', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the string procedure' do
          checks = [
            ['(string)', ''],
            ['(string #\a #\b #\c)', 'abc'],
            ['(string #\H #\e #\l #\l #\o #\x021 #\newline)', "Hello!\n"]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the make-string procedure' do
          checks = [
            ['(make-string 0)', ''],
            ['(make-string 0 #\x)', ''],
            ['(make-string 5 #\x)', 'x' * 5]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the string-append procedure' do
          checks = [
            ['(string-append)', ''],
            ['(string-append "abc" "def")', 'abcdef'],
            ['(string-append "Hey " "you " "there!")', 'Hey you there!']
          ]
          compare_to_predicted(checks)
        end

        it 'implements the string-length procedure' do
          checks = [
            ['(string-length "abc")', 3],
            ['(string-length "")', 0],
            ['(string-length "hi there")', 8]
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'Symbol procedures:' do
        it 'implements the symbol? procedure' do
          checks = [
            ["(symbol? 'foo)", true],
            ["(symbol? (car '(a b)))", true],
            ['(symbol? "bar")', false],
            ["(symbol? 'nil)", true],
            ["(symbol? '())", false],
            ['(symbol? #f)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the symbol->string procedure' do
          checks = [
            ["(equal? (symbol->string 'Hi) \"Hi\")", true],
            ["(equal? (symbol->string 'flying-fish) \"flying-fish\")", true],
            ["(equal? (symbol->string 'Martin) \"Martin\")", true],
            ['(equal? (symbol->string (string->symbol "Malvina")) "Malvina")', true]
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'List procedures:' do
        it 'implements the pair? procedure' do
          checks = [
            ["(pair? '(a . b))", true],
            ["(pair? '(a b c))", true],
            ["(pair? '())", false],
            ["(pair? '#(a b))", false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the list? procedure' do
          checks = [
            ['(list? #f)', false],
            ['(list? 1)', false],
            ['(list? "bar")', false],
            ["(list? 'a)", false],
            ["(list? '(a))", true],
            ["(list? '(1 2 3))", true],
            ["(list? '(3 . 4))", false],
            ["(list? '())", true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the null? procedure' do
          checks = [
            ['(null? #f)', false],
            ['(null? 1)', false],
            ['(null? 0)', false],
            ['(null? "bar")', false],
            ['(null? "")', false],
            ["(null? '(1 2 3))", false],
            ["(list? '())", true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the cons procedure' do
          example = "(cons 'a '())" # => (a)
          result = builder.run(example)
          expect(result).to be_list
          expect(result.car).to eq('a')

          example = "(cons '(a) '(b c d))" # => ((a) b c d)
          result = builder.run(example)
          expect(result).to be_list
          members = result.to_a
          expect(members[0]).to be_list
          expect(members[0].car).to eq('a')
          expect(members[1]).to eq('b')
          expect(members[2]).to eq('c')
          expect(members[3]).to eq('d')

          example = "(cons \"a\" '(b c))" # => ("a" b c)
          result = builder.run(example)
          expect(result).to be_list
          expect(result.car).to be_a(SkmString)
          expect(result.car).to eq('a')
          expect(result.cdr.car).to be_a(SkmIdentifier)
          expect(result.cdr.car).to eq('b')
          expect(result.cdr.cdr.car).to be_a(SkmIdentifier)
          expect(result.cdr.cdr.car).to eq('c')

          example = "(cons 'a 3)" # => (a . 3)
          result = builder.run(example)
          expect(result.car).to eq('a')
          expect(result.cdr).to eq(3)

          example = "(cons '(a b) 'c)" # => ((a b) . c)
          result = builder.run(example)
          expect(result.car).to be_a(SkmPair)
          expect(result.car.to_a).to eq(%w[a b])
          expect(result.cdr).to be_a(SkmIdentifier)
          expect(result.cdr).to eq('c')
        end

        it 'implements the car procedure' do
          expect_expr("(car '(a b c))").to eq('a')

          example = "(car '((a) b c d))" # => (a)
          result = builder.run(example)
          expect(result).to be_list
          expect(result.length).to eq(1)
          expect(result.car).to eq('a')

          expect_expr("(car '(1 . 2))").to eq(1)

          example = "(car '())" # => error
          expect { builder.run(example) }.to raise_error(StandardError)
        end

        it 'implements the cdr procedure' do
          example = "(cdr '((a) b c d))" # => (b c d)
          result = builder.run(example)
          expect(result).to be_list
          expect(result.length).to eq(3)
          expect(result.to_a).to eq(%w[b c d])

          expect_expr("(cdr '(1 . 2))").to eq(2)

          example = "(cdr '())" # => error
          expect { builder.run(example) }.to raise_error(StandardError)
        end

        it 'implements the length procedure' do
          example = '(make-list 2 3)'
          result = builder.run(example)
          expect(result).to be_list
          expect(result.length).to eq(2)
          expect(result.to_a).to eq([3, 3])
        end

        it 'implements the length procedure' do
          checks = [
            ["(length '())", 0],
            ["(length '(1))", 1],
            ["(length '(1 2))", 2],
            ["(length '(1 2 3))", 3],
            ["(length '(a (b) (c d e)))", 3]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the append procedure' do
          checks = [
            ["(append '(a b c) '())", array2list_ids(%w[a b c])],
            ["(append '() '(a b c))", array2list_ids(%w[a b c])],
            ["(append '(x) '(y))", array2list_ids(%w[x y])],
            ["(append '(a) '(b c d))", array2list_ids(%w[a b c d])],
            ["(append '(a b) '(c d))", array2list_ids(%w[a b c d])],
            ["(append '(a b) '(c) 'd)", array2list_ids(%w[a b c d])],
            ["(append '(a (b)) '((c)))", [SkmIdentifier.create('a'),
              SkmPair.create_from_a(array2list_ids(['b'])),
              SkmPair.create_from_a(array2list_ids(['c']))]],
            ["(append '() 'a)", SkmIdentifier.create('a')]
          ]
          compare_to_predicted(checks) do |result, expectation|
            if result.kind_of?(SkmPair)
              expect(result.to_a).to eq(expectation)
            else
              expect(result).to eq(expectation)
            end
          end
        end

        it 'implements the procedure for an improper list' do
          result = builder.run("(append '(a b) '(c . d))")
          expect(result.car).to eq(SkmIdentifier.create('a'))
          expect(result.cdr.car).to eq(SkmIdentifier.create('b'))
          expect(result.cdr.cdr.car).to eq(SkmIdentifier.create('c'))
          expect(result.cdr.cdr.cdr).to eq(SkmIdentifier.create('d'))
        end


        it 'implements the reverse procedure' do
          checks = [
            ["(reverse '())", SkmEmptyList.instance],
            ["(reverse '(a b c))", array2list_ids(%w[c b a])],
            ["(reverse '((a) b c))", array2list_ids(%w[c b]) << SkmPair.new(SkmIdentifier.create('a'), nil)]
          ]
          compare_to_predicted(checks) do |result, expectation|
            if result.kind_of?(SkmPair)
              expect(result.to_a).to eq(expectation)
            else
              expect(result).to eq(expectation)
            end
          end
        end

        it 'implements the list->vector procedure' do
          checks = [
            ["(list->vector '())", []],
            ["(list->vector '(a b c))", %w[a b c]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect(result.to_a).to eq(expectation)
          end
        end

        it 'implements the set-car! procedure' do
          source = <<-SKEEM
  (define x '(a b c))
  (set-car! x 1)
  x
SKEEM
          result = builder.run(source)
          expect(result.last.car).to eq(1)
        end

        it 'implements the set-cdr! procedure' do
          source = <<-SKEEM
  (define x '(a b c))
  (set-cdr! x 1)
  x
SKEEM
          result = builder.run(source)
          expect(result.last.cdr).to eq(1)
        end

        it 'implements the assq procedure' do
          builder.run("(define e '((a 1) (b 2) (c 3)))")
          checks = [
            ["(assq 'a e)", ['a', 1]],
            ["(assq 'b e)", ['b', 2]],
            ["(assq 'c e)", ['c', 3]],
            ["(assq 'd e)", [nil]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect(result.to_a).to eq(expectation)
          end

          expect_expr("(assq 'a '())").to eq(false)
          expect_expr("(assq 'a '())").to eq(false)
          expect_expr("(assq '(a) '(((a)) ((b)) ((c))))").to eq(false)
        end

        it 'implements the assv procedure' do
          result = builder.run("(assv 5 '((2 3) (5 7) (11 13)))")
          expect(result.to_a).to eq([5, 7])
        end

        it 'implements the list-copy procedure' do
          checks = [
            ["(list-copy '())", []],
            ["(list-copy '(a b c))", %w[a b c]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect(result.to_a).to eq(expectation)
          end

          source = <<-SKEEM
  (define a '(1 8 2 8)) ; a may be immutable
  (define b (list-copy a))
  (set-car! b 3) ; b is mutable
SKEEM
          builder.run(source)
          result = builder.run('b')
          expect(result.to_a).to eq([3, 8, 2, 8])
          result = builder.run('a')
          expect(result.to_a).to eq([1, 8, 2, 8])
        end
      end # context

      context 'Character procedures:' do
        it 'implements the char? procedure' do
          checks = [
            ['(char? #f)', false],
            ["(char? 'a)", false],
            ['(char? #\a)', true],
            ['(char? "a")', false],
            ["(char? '(#\\a 1))", false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the char->integer procedure' do
          checks = [
            ['(char->integer #\space)', 0x20],
            ['(char->integer #\newline)', 0x0a],
            ['(char->integer #\a)', ?a.ord],
            ['(char->integer #\x05a)', 0x5a]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the integer->char procedure' do
          checks = [
            ['(integer->char #x20)', ?\s],
            ['(integer->char 48)', ?0],
            ['(integer->char #x0a)', ?\n],
            ['(integer->char #x3bb)', ?\u03bb]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the char=? procedure' do
          checks = [
            ['(char=? #\a)', true],
            ['(char=? #\a #\a)', true],
            ['(char=? #\a #\b)', false],
            ['(char=? #\space #\space #\space)', true],
            ['(char=? #\space #\space #\newline)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the char<? procedure' do
          checks = [
            ['(char<? #\a)', true],
            ['(char<? #\a #\a)', false],
            ['(char<? #\a #\b)', true],
            ['(char<? #\a #\b #\c)', true],
            ['(char<? #\a #\c #\b)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the char>? procedure' do
          checks = [
            ['(char>? #\b)', true],
            ['(char>? #\b #\b)', false],
            ['(char>? #\b #\a)', true],
            ['(char>? #\c #\b #\a)', true],
            ['(char>? #\c #\a #\b)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the char<=? procedure' do
          checks = [
            ['(char<=? #\a)', true],
            ['(char<=? #\a #\a)', true],
            ['(char<=? #\b #\a)', false],
            ['(char<=? #\a #\b #\c)', true],
            ['(char<=? #\a #\c #\c)', true],
            ['(char<=? #\a #\c #\b)', false]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the char>=? procedure' do
          checks = [
            ['(char>=? #\a)', true],
            ['(char>=? #\a #\a)', true],
            ['(char>=? #\a #\b)', false],
            ['(char>=? #\c #\b #\a)', true],
            ['(char>=? #\c #\b #\b)', true],
            ['(char>=? #\c #\a #\b)', false]
          ]
          compare_to_predicted(checks)
        end
      end # context

      context 'Vector procedures:' do
        it 'implements the vector? procedure' do
          checks = [
            ['(vector? #f)', false],
            ['(vector? 1)', false],
            ['(vector? "bar")', false],
            ["(vector? '(1 2 3))", false],
            ['(vector? #(1 #f "cool"))', true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the vector procedure' do
          source = '(vector)'
          result = builder.run(source)
          expect(result).to be_a(SkmVector)
          expect(result).to be_empty

          source = '(vector 1 2 3)'
          result = builder.run(source)
          expect(result).to be_a(SkmVector)
          expect(result.members).to eq([1, 2, 3])
        end

        it 'implements the vector-length procedure' do
          checks = [
            ['(vector-length (vector))', 0],
            ['(vector-length #())', 0],
            ['(vector-length (vector 1))', 1],
            ['(vector-length #(1))', 1],
            ['(vector-length (vector 1 2))', 2],
            ['(vector-length #(1 2))', 2],
            ['(vector-length (vector 1 2 3))', 3]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the make-vector procedure' do
          checks = [
            ['(vector-length (make-vector 0))', 0],
            ["(vector-length (make-vector 0 'a))", 0],
            ["(equal? (make-vector 5 'a) '#(a a a a a))", true]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the vector-ref procedure' do
          source = "(vector-ref '#(1 1 2 3 5 8 13 21) 5)"
          result = builder.run(source)
          expect(result).to be_a(SkmInteger)
          expect(result).to eq(8)
        end

        it 'implements the vector-set! procedure' do
          source = <<-SKEEM
  (let
    ((vec (vector 0 '(2 2 2 2) "Anna")))
    (vector-set! vec 1 '("Sue" "Sue"))
  vec)
SKEEM
          # (0 ("Sue" "Sue") "Anna")
          result = builder.run(source)
          expect(result).to be_a(SkmVector)
          expectation = [SkmInteger.create(0),
            SkmPair.new(SkmString.create('Sue'), SkmPair.new(SkmString.create('Sue'), SkmEmptyList.instance)),
            SkmString.create('Anna')]
          expect(result).to eq(expectation)

          source = <<-SKEEM
  (let (
    (v (vector 'a 'b 'c 'd 'e)))
    (vector-set! v 2 'x)
    v)
SKEEM
          result = builder.run(source)
          expect(result).to be_a(SkmVector)
          expect(result).to eq(array2list_ids(%w[a b x d e]))
        end

        it 'implements the vector->list procedure' do
          checks = [
            ['(vector->list #())', []],
            ["(vector->list '#(a b c))", %w[a b c]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect(result.to_a).to eq(expectation)
          end
        end
      end # context

      context 'Control procedures:' do
        it 'implements the procedure? predicate' do
          checks = [
            ['(procedure? car)', true],
            ["(procedure? 'car)", false],
            ['(procedure? (lambda (x) (* x x)))', true]
            # ["(procedure? '(lambda (x) (* x x)))", false] # Parse fail: non-standard syntax
          ]
          compare_to_predicted(checks)
        end

        it 'implements the apply procedure' do
          checks = [
            ["(apply + '(3 4))", 7]
          ]
          compare_to_predicted(checks)
        end

        it 'implements the map procedure' do
          checks = [
            ["(map car '((a b) (d e) (g h)))", %w[a d g]],
            ["(map + '(1 2 3) '(4 5 6 7))", [5, 7, 9]]
          ]
          compare_to_predicted(checks) do |result, expectation|
            expect(result.to_a).to eq(expectation)
          end
        end
      end # context

      context 'IO procedures:' do
        it 'implements the display procedure' do
          expect { builder.run('(display "Hello")') }.to output('Hello').to_stdout
        end
      end # context

      context 'Miscellaneous procedures' do
        it 'raises an exception with given error message' do
          source = '(error "This is an error message")'
          err = SkmError
          msg = 'This is an error message'
          expect { builder.run(source) }.to raise_error(err, msg)
        end

        it 'returns true when an assertion succeeds' do
          source = <<-SKEEM
  (define x 2)
  (define y 1)
  (test-assert (> x y))
SKEEM
          expect(builder.run(source).last).to eq(true)
        end

        it 'raises an error when an assertion fails' do
          source = <<-SKEEM
  (define x 1)
  (define y 2)
  (test-assert (> x y))
SKEEM
          err = StandardError
          msg1 = 'Error: assertion failed on line 3, column 4'
          msg2 = 'with <Skeem::SkmBoolean: false>'
          expect { builder.run(source) }.to raise_error(err, "#{msg1}, #{msg2}")
        end
      end # context
    end # describe
  end # module
end # module
