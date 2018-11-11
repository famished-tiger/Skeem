require_relative '../../spec_helper' # Use the RSpec framework

# Load the class under test
require_relative '../../../lib/skeem/interpreter'

module Skeem
  module Primitive
    describe 'Testing primitive procedures' do
      subject { Interpreter.new }
      
      context 'Arithmetic operators:' do
        it 'should implement the set! form' do
          skeem1 = <<-SKEEM
  (define x 2)
  (+ x 1)
SKEEM
          result = subject.run(skeem1)
          expect(result.last).to eq(3)  # x is bound to value 2
          skeem2 = <<-SKEEM
  (set! x 4)
  (+ x 1)
SKEEM
          result = subject.run(skeem2)
          expect(result.last).to eq(5)  # x is now bound to value 4
        end        
      end # context

      context 'Arithmetic operators:' do
        it 'should implement the addition operator' do
          [
            ['(+)', 0], # '+' as nullary operator. Example from section 6.2.6
            ['(+ -3)', -3], # '+' as unary operator
            ['(+ 3 4)', 7], # '+' as binary operator. Example from section 4.1.3
            ['(+ 2 2.34)', 4.34]
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result).to eq(predicted)
          end
        end

        it 'should implement the minus operator' do
          [
            ['(- 3)', -3], # '-' as unary operator (= sign change)
            ['(- 3 4)', -1], # '-' as binary operator. Example from section 6.2.6
            ['(- 3 4 5)', -6] # '-' as variadic operator. Example from section 6.2.6
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result).to eq(predicted)
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
            expect(result).to eq(predicted)
          end
        end

        it 'should implement the division operator' do
          [
            ['(/ 3)', 1.0/3], # '/' as unary operator (= inverse of argument)
            ['(/ 3 4)', 3.0/4], # '/' as binary operator.
            ['(/ 3 4 5)', 3.0/20] # '/' as variadic operator. Example from section 6.2.6
          ].each do |(expr, predicted)|
            result = subject.run(expr)
            expect(result).to eq(predicted)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
          end
        end
      end # context

      context 'Number procedures:' do
        it 'should implement the number? predicate' do
          checks = [
            ['(number? 3.1)', true],
            ['(number? 3)', true],
            ['(number? "3")', false],
            ['(number? #t)', false]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the number->string procedure' do
          checks = [
            ['(number->string 3.4)', '3.4'],
            ['(number->string 1e2)', '100.0'],
            ['(number->string 1e-23)', '1.0e-23'],
            ['(number->string -7)', '-7']
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the and procedure' do
          checks = [
            ['(and (= 2 2) (> 2 1))', true],
            ['(and (= 2 2) (< 2 1))', false],
            ['(and)', true]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end

          # If all the expressions evaluate to true values,
          # the values of the last expression are returned.
          source = "(and 1 2 'c '(f g))"
          result = subject.run(source)
          expect(result).to be_kind_of(SkmList)
          expect(result.head).to eq('f')
          expect(result.last).to eq('g')
        end

        it 'should implement the or procedure' do
          checks = [
            ['(or (= 2 2) (> 2 1))', true],
            ['(or (= 2 2) (< 2 1))', true],
            ['(or)', false],
            ['(or #f)', false],
            ['(or #f #t)', true],
            ['(or #f #f #f)', false],

          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end

          # When an expression evaluates to true value,
          # the values of the this expression is returned.
          source = "(or #f 'a #f)"
          result = subject.run(source)
          expect(result).to be_kind_of(SkmIdentifier)
          expect(result).to eq('a')
        end

        it 'should implement the boolean? procedure' do
          checks = [
            ['(boolean? #f)', true],
            ['(boolean? 0)', false]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the string->symbol procedure' do
          checks = [
            ['(string->symbol "mISSISSIppi")', 'mISSISSIppi']
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the string=? procedure' do
          checks = [
            ['(string=? "Mom" "Mom")', true],
            ['(string=? "Mom" "Mum")', false],
            ['(string=? "Mom" "Dad")', false]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the string-append procedure' do
          checks = [
            ['(string-append)', ''],
            ['(string-append "abc" "def")', 'abcdef'],
            ['(string-append "Hey " "you " "there!")', 'Hey you there!']
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end

       it 'should implement the string-length procedure' do
          checks = [
            ['(string-length "abc")', 3],
            ['(string-length "")', 0],
            ['(string-length "hi there")', 8],
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end
      end # context

      context 'Symbol procedures:' do
        it 'should implement the symbol? procedure' do
          checks = [
            ['(symbol? #f)', false],
            ['(symbol? "bar")', false],
            ["(symbol? '())", false],
            ["(symbol? 'foo)", true],
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
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
            expect(result).to eq(expectation)
          end
        end
      end # context

      context 'Vector procedures:' do
        it 'should implement the vector? procedure' do
          checks = [
            ['(vector? #f)', false],
            ['(vector? 1)', false],
            ['(vector? "bar")', false],
            ['(vector? (list 1 2 3))', false],
            ['(vector? #(1 #f "cool"))', true]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the vector procedure' do
          source = '(vector)'
          result = subject.run(source)
          expect(result).to be_kind_of(SkmVector)
          expect(result).to be_empty

          source = '(vector 1 2 3)'
          result = subject.run(source)
          expect(result).to be_kind_of(SkmVector)
          expect(result.members).to eq([1, 2, 3])
        end

        it 'should implement the vector-length procedure' do
          checks = [
            ['(vector-length (vector))', 0],
            ['(vector-length #())', 0],
            ['(vector-length (vector 1))', 1],
            ['(vector-length #(1))', 1],
            ['(vector-length (vector 1 2))', 2],
            ['(vector-length #(1 2))', 2],
            ['(vector-length (vector 1 2 3))', 3]
          ]
          checks.each do |(skeem_expr, expectation)|
            result = subject.run(skeem_expr)
            expect(result).to eq(expectation)
          end
        end

        it 'should implement the vector-ref procedure' do
          source = "(vector-ref '#(1 1 2 3 5 8 13 21) 5)"
          result = subject.run(source)
          expect(result).to be_kind_of(SkmInteger)
          expect(result).to eq(8)
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