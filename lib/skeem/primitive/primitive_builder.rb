require_relative '../primitive_procedure'
require_relative '../convertible'

module Skeem
  module Primitive
    module PrimitiveBuilder
      include Convertible
      def add_primitives(aRuntime)
        add_arithmetic(aRuntime)
        add_comparison(aRuntime)
        add_number_predicates(aRuntime)
        add_boolean_procedures(aRuntime)
        add_string_procedures(aRuntime)
        add_symbol_procedures(aRuntime)
      end

      private

      def add_arithmetic(aRuntime)
        def_procedure(aRuntime, create_plus)
        def_procedure(aRuntime, create_minus)
        def_procedure(aRuntime, create_multiply)
        def_procedure(aRuntime, create_divide)
      end

      def add_comparison(aRuntime)
        def_procedure(aRuntime, create_equal)
        def_procedure(aRuntime, create_lt)
        def_procedure(aRuntime, create_gt)
        def_procedure(aRuntime, create_lte)
        def_procedure(aRuntime, create_gte)
      end

      def add_number_predicates(aRuntime)
        def_procedure(aRuntime, create_number?)
        def_procedure(aRuntime, create_real?)
        def_procedure(aRuntime, create_integer?)
      end

      def add_boolean_procedures(aRuntime)
        def_procedure(aRuntime, create_not)
        def_procedure(aRuntime, create_boolean?)
      end

      def add_string_procedures(aRuntime)
        def_procedure(aRuntime, create_string?)
      end

      def add_symbol_procedures(aRuntime)
        def_procedure(aRuntime, create_symbol?)
      end

      def create_plus()
        plus_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result += elem.value }
          to_skm(raw_result)
        end

        ['+', plus_code]
      end

      def create_minus()
        minus_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          raw_result = first_one.value
          if arglist.length > 1
            operands = arglist.tail.to_eval_enum(runtime)
            operands.each { |elem| raw_result -= elem.value }
          else
            raw_result = -raw_result
          end
          to_skm(raw_result)
        end

        ['-', minus_code]
      end

      def create_multiply()
        multiply_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result *= elem.value }
          to_skm(raw_result)
        end

        ['*', multiply_code]
      end

      def create_divide()
        divide_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          raw_result = first_one.value
          operands.each { |elem| raw_result /= elem.value }
          to_skm(raw_result)
        end

        ['/', divide_code]
      end

      def create_equal
        equal_code = ->(runtime, arglist) do
          first_one = arglist.head.evaluate(runtime)
          operands = arglist.tail.to_eval_enum(runtime)
          first_value = first_one.value
          all_equal = operands.all? { |elem| first_value == elem.value }
          to_skm(all_equal)
        end

        ['=', equal_code]
      end

      def create_lt
        lt_code = ->(runtime, arglist) do
          operands = arglist.to_eval_enum(runtime)
          result = true
          operands.each_cons(2) do |(elem1, elem2)|
            result &&= elem1.value < elem2.value
          end
          to_skm(result)
        end

        ['<', lt_code]
      end

      def create_gt
        gt_code = ->(runtime, arglist) do
          operands = arglist.to_eval_enum(runtime)
          result = true
          operands.each_cons(2) do |(elem1, elem2)|
            result &&= elem1.value > elem2.value
          end
          to_skm(result)
        end

        ['>', gt_code]
      end

      def create_lte
        lte_code = ->(runtime, arglist) do
          operands = arglist.to_eval_enum(runtime)
          result = true
          operands.each_cons(2) do |(elem1, elem2)|
            result &&= elem1.value <= elem2.value
          end
          to_skm(result)
        end

        ['<=', lte_code]
      end

      def create_gte
        gte_code = ->(runtime, arglist) do
          operands = arglist.to_eval_enum(runtime)
          result = true
          operands.each_cons(2) do |(elem1, elem2)|
            result &&= elem1.value >= elem2.value
          end
          to_skm(result)
        end

        ['>=', gte_code]
      end

      def create_number?()
        pred_code = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.number?)
        end

        ['number?', pred_code]
      end

      def create_real?()
        pred_code = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.real?)
        end

        ['real?', pred_code]
      end

      def create_integer?()
        pred_code = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.integer?)
        end

        ['integer?', pred_code]
      end

      def create_not()
        logical = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          if arg_evaluated.boolean? && arg_evaluated.value == false
            to_skm(true)
          else
            to_skm(false)
          end
        end
        ['not', logical]
      end

      def create_boolean?()
        pred_code = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.boolean?)
        end

        ['boolean?', pred_code]
      end

      def create_string?()
        pred_code = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.string?)
        end

        ['string?', pred_code]
      end

      def create_symbol?
        pred_code = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.symbol?)
        end

        ['symbol?', pred_code]
      end

      def def_procedure(aRuntime, aPair)
        func = PrimitiveProcedure.new(aPair.first, aPair.last)
        define(aRuntime, func.identifier, func)
      end

      def define(aRuntime, aKey, anEntry)
        aRuntime.define(aKey, anEntry)
      end
    end # module
  end # module
end # module