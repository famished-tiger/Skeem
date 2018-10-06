require 'stringio'
require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/interpreter' # Load the class under test

module Skeem
  describe Interpreter do
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
          expect(result.value).to eq(predicted)
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
          expect(result.value).to eq(predicted)
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
          expect(result.value).to eq(predicted)
        end
      end

      it 'should evaluate isolated strings' do
        samples = [
        ['"Hello, world"', 'Hello, world']
      ]
        samples.each do |source, predicted|
          result = subject.run(source)
          expect(result).to be_kind_of(SkmString)
          expect(result.value).to eq(predicted)
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
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(28)
      end

      it 'should implement the simple conditional form' do
         checks = [
          ['(if (> 3 2) "yes")', 'yes'],
          ['(if (> 2 3) "yes")', :UNDEFINED]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the complete conditional form' do
         checks = [
          ['(if (> 3 2) "yes" "no")', 'yes'],
          ['(if (> 2 3) "yes" "no")', 'no']
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
        source = <<-SKEEM
  ; Example from R7RS section 4.1.5
  (if (> 3 2)
    (- 3 2)
    (+ 3 2))
SKEEM
        result = subject.run(source)
        expect(result.value).to eq(1)
      end

      it 'should implement the lambda function with one arg' do
        source = <<-SKEEM
  ; Simplified 'abs' function implementation
  (define abs 
    (lambda (x)
      (if (< x 0) (- x) x)))
SKEEM
        subject.run(source)
        result = subject.run('(abs -3)')
        expect(result.value).to eq(3)
        result = subject.run('(abs 0)')
        expect(result.value).to eq(0)
        result = subject.run('(abs 3)')
        expect(result.value).to eq(3)
      end
      
      it 'should implement the lambda function with two args' do
        source = <<-SKEEM
  ; Simplified 'min' function implementation
  (define min 
    (lambda (x y)
      (if (< x y) x y)))
SKEEM
        subject.run(source)
        result = subject.run('(min 1 2)')
        expect(result.value).to eq(1)
        result = subject.run('(min 2 1)')
        expect(result.value).to eq(1)
        result = subject.run('(min 2 2)')
        expect(result.value).to eq(2)
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
        expect(result.value).to eq(3628800)    
      end
      
    it 'should implement the compact define + lambda syntax' do
        source = <<-SKEEM
  ; Alternative syntax to: (define f (lambda x (+ x 42)))
  (define (f x)
    (+ x 42))
  (f 23)
SKEEM
        result = subject.run(source)
        expect(result.value).to eq(65)      
    end
    end # context

    context 'Built-in primitive procedures' do
      it 'should implement the addition of integers' do
        result = subject.run('(+ 2 2)')
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(4)
      end

      it 'should implement the addition of real numbers' do
        result = subject.run('(+ 2 2.34)')
        expect(result).to be_kind_of(SkmReal)
        expect(result.value).to eq(4.34)
      end

      it 'should implement the negation of integer' do
        result = subject.run('(- 3)')
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(-3)
      end

      it 'should implement the substraction of integers' do
        result = subject.run('(- 3 4)')
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(-1)

        result = subject.run('(- 3 4 5)')
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(-6)
      end

      it 'should implement the product of numbers' do
        checks = [
          ['(* 5 8)', 40],
          ['(* 2 3 4)', 24]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the division of numbers' do
        result = subject.run('(/ 24 3)')
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(8)
      end

      it 'should implement the arithmetic expressions' do
        result = subject.run('(+ (* 2 100) (* 1 10))')
        expect(result).to be_kind_of(SkmInteger)
        expect(result.value).to eq(210)
      end
      
      it 'should implement the floor-remainder (modulo) procedure' do
        checks = [
          ['(modulo 16 4)', 0],
          ['(modulo 5 2)', 1],
          ['(modulo -45.0 7)', 4.0],
          ['(modulo 10.0 -3.0)', -2.0],
          ['(modulo -17 -9)', -8]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the equality operator' do
        checks = [
          ['(= 3 3)', true],
          ['(= 3 (+ 1 2) (- 4 1))', true],
          ['(= "foo" "foo")', true],
          ['(= 3 4)', false],
          ['(= "foo" "bar")', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the less than operator' do
        checks = [
          ['(< 3 4)', true],
          ['(< 3 (+ 2 2) (+ 4 1))', true],
          ['(< 3 3)', false],
          ['(< 3 2)', false],
          ['(< 3 4 5 4)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the greater than operator' do
        checks = [
          ['(> 3 2)', true],
          ['(> 3 (- 4 2) (- 2 1))', true],
          ['(> 3 3)', false],
          ['(> 3 4)', false],
          ['(> 3 2 1 2)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the less or equal than operator' do
        checks = [
          ['(<= 3 4)', true],
          ['(<= 3 (+ 2 2) (+ 4 1))', true],
          ['(<= 3 3)', true],
          ['(<= 3 2)', false],
          ['(<= 3 4 5 4)', false],
          ['(<= 3 4 5 5)', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the greater or equal than operator' do
        checks = [
          ['(>= 3 2)', true],
          ['(>= 3 (- 4 2) (- 2 1))', true],
          ['(>= 3 3)', true],
          ['(>= 3 4)', false],
          ['(>= 3 2 1 2)', false],
          ['(>= 3 2 1 1)', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the number? predicate' do
        checks = [
          ['(number? 3.1)', true],
          ['(number? 3)', true],
          ['(number? "3")', false],
          ['(number? #t)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the real? predicate' do
        checks = [
          ['(real? 3.1)', true],
          ['(real? 3)', true],
          ['(real? "3")', false],
          ['(real? #t)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the integer? predicate' do
        checks = [
          ['(integer? 3.1)', false],
          # ['(integer? 3.0)', true], TODO: should pass when exact? will be implemented
          ['(integer? 3)', true],
          ['(integer? "3")', false],
          ['(integer? #t)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the not procedure' do
        checks = [
          ['(not #t)', false],
          ['(not 3)', false],
          ['(not #f)', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the boolean? procedure' do
        checks = [
          ['(boolean? #f)', true],
          ['(boolean? 0)', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the string? procedure' do
        checks = [
          ['(string? #f)', false],
          ['(string? 3)', false],
          ['(string? "hi")', true]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end

      it 'should implement the symbol? procedure' do
        checks = [
          ['(symbol? #f)', false],
          ['(symbol? "bar")', false]
        ]
        checks.each do |(skeem_expr, expectation)|
          result = subject.run(skeem_expr)
          expect(result.value).to eq(expectation)
        end
      end
      
      it 'should implement the newline procedure' do
        default_stdout = $stdout
        $stdout = StringIO.new()
        subject.run('(newline) (newline) (newline)')
        expect($stdout.string).to match(/\n\n\n$/)
        $stdout = default_stdout
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
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
          expect(result.value).to eq(expectation)
        end
      end      
    end # context
  end # describe
end # module