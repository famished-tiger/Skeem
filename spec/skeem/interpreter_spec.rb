require_relative '../spec_helper' # Use the RSpec framework
require_relative '../../lib/skeem/interpreter' # Load the class under test

module Skeem
  describe Interpreter do
    context 'Initialization:' do
      it 'should be initialized without argument' do
        expect { Interpreter.new() }.not_to raise_error
      end

      it 'should not have a parser' do
        expect(subject.parser).to be_nil
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
    end # context
  end # describe
end # module