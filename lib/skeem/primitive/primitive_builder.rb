require_relative '../primitive_func'

module Skeem
  module Primitive
    module PrimitiveBuilder
      def add_primitives(aRuntime)
        add_arithmetic(aRuntime)
      end
      
      private
      
      def add_arithmetic(aRuntime)
        def_func(aRuntime, create_plus)
        def_func(aRuntime, create_minus)
        def_func(aRuntime, create_multiply)
        def_func(aRuntime, create_divide)
      end
      
      def create_plus()
        plus_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result += elem.value }
          if raw_result.kind_of?(Float) 
            SExprReal.create(raw_result)
          else
            SExprInteger.create(raw_result)
          end
        end

        ['+', plus_code]
      end
      
      def create_minus()
        minus_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result -= elem.value } 
          if raw_result.kind_of?(Float) 
            SExprReal.create(raw_result)
          else
            SExprInteger.create(raw_result)
          end
        end

        ['-', minus_code]
      end

      def create_multiply()
        multiply_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result *= elem.value }          
          if raw_result.kind_of?(Float) 
            SExprReal.create(raw_result)
          else
            SExprInteger.create(raw_result)
          end
        end

        ['*', multiply_code]
      end

      def create_divide()
        divide_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result /= elem.value }
          if raw_result.kind_of?(Float) 
            SExprReal.create(raw_result)
          else
            SExprInteger.create(raw_result)
          end
        end

        ['/', divide_code]
      end       
      
      def def_func(aRuntime, aPair)
        func = PrimitiveFunc.new(aPair.first, aPair.last)
        define(aRuntime, func.identifier, func)
      end

      def define(aRuntime, aKey, anEntry)
        aRuntime.define(aKey, anEntry)
      end
    end # module
  end # module
end # module