require_relative '../../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../../lib/skeem/interpreter'

module Skeem
  module Primitive
    describe 'Testing primitive procedures' do
        subject { Interpreter.new }
        context 'Arithmetic operators:' do
        it 'should implement the addition operator' do
          [
            ['(+)', 0], # '+' as nullary operator. Example from section 6.2.6
            ['(+ -3)', -3], # '+' as unary operator
            ['(+ 3 4)', 7], # '+' as binary operator. Example from section 4.1.3
            ['(+ 2 2.34)', 4.34]
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result.value).to eq(predicted)
          end
        end

        it 'should implement the minus operator' do
          [
            ['(- 3)', -3], # '-' as unary operator (= sign change)
            ['(- 3 4)', -1], # '-' as binary operator. Example from section 6.2.6
            ['(- 3 4 5)', -6] # '-' as variadic operator. Example from section 6.2.6
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result.value).to eq(predicted)
          end
        end

        it 'should implement the product operator' do
          [
            ['(*)', 1], # '*' as nullary operator. Example from section 6.2.6
            ['(* 4)', 4], # '*' as unary operator. Example from section 6.2.6
            ['(* 5 8)', 40], # '*' as binary operator.
            ['(* 2 3 4 5)', 120] # '*' as variadic operator.
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result.value).to eq(predicted)
          end
        end

        it 'should implement the division operator' do
          [
            ['(/ 3)', 1.0/3], # '/' as unary operator (= inverse of argument)
            ['(/ 3 4)', 3.0/4], # '/' as binary operator.
            ['(/ 3 4 5)', 3.0/20] # '/' as variadic operator. Example from section 6.2.6
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result.value).to eq(predicted)
          end
        end

        it 'should implement the floor-remainder (modulo) procedure' do
          checks = [
            ['(floor-remainder 16 4)', 0], # Binary procedure.
            ['(floor-remainder 5 2)', 1],
            ['(floor-remainder -45.0 7)', 4.0],
            ['(floor-remainder 10.0 -3.0)', -2.0],
            ['(floor-remainder -17 -9)', -8]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result.value).to eq(expectation)
          end
        end
      end # context

      context 'Comparison operators' do
        it 'should implement the equality operator' do
          checks = [
            ['(= 3)', true], # '=' as unary operator
            ['(= 3 3)', true], # '=' as binary operator
            ['(= 3 (+ 1 2) (- 4 1))', true], # '=' as variadic operator
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
            ['(< 3)', false], # '<' as unary operator
            ['(< 3 4)', true], # '<' as binary operator
            ['(< 3 (+ 2 2) (+ 4 1))', true], # '<' as variadic operator
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
            ['(> 3)', false], # '>' as unary operator
            ['(> 3 2)', true], # '>' as binary operator
            ['(> 3 (- 4 2) (- 2 1))', true], # '>' as variadic operator
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
            ['(<= 3)', true], # '<=' as unary operator
            ['(<= 3 4)', true], # '<=' as binary operator
            ['(<= 3 (+ 2 2) (+ 4 1))', true], # '<=' as variadic operator
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
            ['(>= 3)', true], # '>=' as unary operator
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
      end # context

      context 'Number predicates:' do
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
      end # context
      
      context 'Boolean procedures:' do
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
      end # context
      
      context 'String procedures:' do
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
      end # context
      
      context 'Symbol procedures:' do      
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
      
      context 'List procedures:' do      
        it 'should implement the list? procedure' do
          checks = [
            ['(list? #f)', false],
            ['(list? 1)', false],
            ['(list? "bar")', false],
            ['(list? (list 1 2 3))', true],
            ['(list? (list))', true]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result.value).to eq(expectation)
          end
        end
        
          it 'should implement the null? procedure' do
          checks = [
            ['(null? #f)', false],
            ['(null? 1)', false],
            ['(null? 0)', false],
            ['(null? "bar")', false],
            ['(null? "")', false],
            ['(null? (list 1 2 3))', false],
            ['(list? (list))', true]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result.value).to eq(expectation)
          end
        end 

        it 'should implement the length procedure' do
          checks = [
            ['(length (list))', 0],
            ['(length (list 1))', 1],
            ['(length (list 1 2))', 2],
            ['(length (list 1 2 3))', 3]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result.value).to eq(expectation)
          end
        end         
      end # context      
      
      context 'IO procedures:' do          
        it 'should implement the newline procedure' do
          default_stdout = $stdout
          $stdout = StringIO.new()
          subject.run('(newline) (newline) (newline)')
          expect($stdout.string).to match(/\n\n\n$/)
          $stdout = default_stdout
        end
      end # context
    end # describe
  end # module
end # module