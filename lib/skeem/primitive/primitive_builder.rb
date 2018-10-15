require_relative 'primitive_procedure'
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
        add_list_procedures(aRuntime)
        add_io_procedures(aRuntime)
        add_special_procedures(aRuntime)
      end

      private
      
      def nullary
        SkmArity.new(0, 0) 
      end
      
      def unary
        SkmArity.new(1, 1)
      end
      
      def binary
        SkmArity.new(2, 2)
      end
      
      def zero_or_more
        SkmArity.new(0, '*')
      end
      
      def one_or_more
        SkmArity.new(1, '*') 
      end

      def add_arithmetic(aRuntime)
        create_plus(aRuntime)
        create_minus(aRuntime)
        create_multiply(aRuntime)
        create_divide(aRuntime)
        create_modulo(aRuntime)
      end

      def add_comparison(aRuntime)
        create_equal(aRuntime)
        create_lt(aRuntime)
        create_gt(aRuntime)
        create_lte(aRuntime)
        create_gte(aRuntime)
      end

      def add_number_predicates(aRuntime)
        create_number?(aRuntime)
        create_real?(aRuntime)
        create_integer?(aRuntime)
      end

      def add_boolean_procedures(aRuntime)
        create_not(aRuntime)
        create_boolean?(aRuntime)
      end

      def add_string_procedures(aRuntime)
        create_string?(aRuntime)
      end

      def add_symbol_procedures(aRuntime)
        create_symbol?(aRuntime)
      end
      
      def add_list_procedures(aRuntime)
        create_list?(aRuntime)
        create_null?(aRuntime)
        create_length(aRuntime)
      end

      def add_io_procedures(aRuntime)(aRuntime)
        create_newline(aRuntime)
      end

      def add_special_procedures(aRuntime)
        create_debug(aRuntime)
      end

      def create_plus(aRuntime)
        # arglist should be a Ruby Array
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            to_skm(0)
          else
            first_one = arglist.first.evaluate(runtime)
            raw_result = first_one.value
            operands = evaluate_tail(arglist, runtime)
            operands.each { |elem| raw_result += elem.value }
            to_skm(raw_result)
          end
        end
        define_primitive_proc(aRuntime, '+', zero_or_more, primitive)
      end

      def create_minus(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          first_one = first_operand.evaluate(runtime)
          raw_result = first_one.value
          if arglist.empty?
            raw_result = -raw_result
          else
            operands = evaluate_array(arglist, runtime)
            operands.each { |elem| raw_result -= elem.value }
          end
          to_skm(raw_result)
        end

        define_primitive_proc(aRuntime, '-', one_or_more, primitive)
      end

      def create_multiply(aRuntime)
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            to_skm(1)
          else
            first_one = arglist.first.evaluate(runtime)
            raw_result = first_one.value
            operands = evaluate_tail(arglist, runtime)
            operands.each { |elem| raw_result *= elem.value }
            to_skm(raw_result)
          end
        end
        define_primitive_proc(aRuntime, '*', zero_or_more, primitive)
      end

      
      def create_divide(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          first_one = first_operand.evaluate(runtime)
          raw_result = first_one.value
          if arglist.empty?
            raw_result = 1 / raw_result.to_f
          else
            operands = evaluate_array(arglist, runtime)
            operands.each do |elem|
              if raw_result > elem.value && raw_result.modulo(elem.value).zero?
                raw_result /= elem.value
              else
                raw_result = raw_result.to_f
                raw_result /= elem.value
              end
            end
          end
          to_skm(raw_result)
        end
        
        define_primitive_proc(aRuntime, '/', one_or_more, primitive)
      end

      def create_modulo(aRuntime)
          primitive = ->(runtime, argument1, argument2) do 
          operand_1 = argument1.evaluate(runtime)
          operand_2 = argument2.evaluate(runtime)
          raw_result = operand_1.value.modulo(operand_2.value)
          to_skm(raw_result)
        end

        define_primitive_proc(aRuntime, 'floor-remainder', binary, primitive) 
      end

      def create_equal(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          first_one = first_operand.evaluate(runtime)
          if arglist.empty?
            to_skm(true)
          else
            operands = evaluate_array(arglist, runtime)         
            first_value = first_one.value
            all_equal = operands.all? { |elem| first_value == elem.value }
            to_skm(all_equal)
          end
        end

        define_primitive_proc(aRuntime, '=', one_or_more, primitive)
      end

      def create_lt(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            to_skm(false)
          else        
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value < elem2.value
            end
            to_skm(result)
          end
        end

        define_primitive_proc(aRuntime, '<', one_or_more, primitive)
      end

      def create_gt(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            to_skm(false)
          else        
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value > elem2.value
            end
            to_skm(result)
          end
        end

        define_primitive_proc(aRuntime, '>', one_or_more, primitive)
      end

      def create_lte(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            to_skm(true)
          else        
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value <= elem2.value
            end
            to_skm(result)
          end
        end

        define_primitive_proc(aRuntime, '<=', one_or_more, primitive)
      end

      def create_gte(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            to_skm(true)
          else        
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value >= elem2.value
            end
            to_skm(result)
          end
        end

        define_primitive_proc(aRuntime, '>=', one_or_more, primitive)
      end

      def create_number?(aRuntime)
         primitive = ->(runtime, object) do
          arg_evaluated = object.evaluate(runtime)
          to_skm(arg_evaluated.number?)
        end

        define_primitive_proc(aRuntime, 'number?', unary, primitive)
      end

      def create_real?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.real?)
        end

        define_primitive_proc(aRuntime, 'real?', unary, primitive)
      end

      def create_integer?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.integer?)
        end

        define_primitive_proc(aRuntime, 'integer?', unary, primitive)
      end

      def create_not(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          if arg_evaluated.boolean? && arg_evaluated.value == false
            to_skm(true)
          else
            to_skm(false)
          end
        end
        
        define_primitive_proc(aRuntime, 'not', unary, primitive)
      end

      def create_boolean?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.boolean?)
        end

        define_primitive_proc(aRuntime, 'boolean?', unary, primitive)
      end

      def create_string?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.string?)
        end

        define_primitive_proc(aRuntime, 'string?', unary, primitive)
      end

      def create_symbol?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.symbol?)
        end

        define_primitive_proc(aRuntime, 'symbol?', unary, primitive)
      end
      
      def create_list?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.list?)
        end

        define_primitive_proc(aRuntime, 'list?', unary, primitive)
      end

      def create_null?(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_skm(arg_evaluated.null?)
        end

        define_primitive_proc(aRuntime, 'null?', unary, primitive)
      end       
      
      def create_length(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          unless arg_evaluated.kind_of?(SkmList)
            msg1 = "Procedure 'length': list argument required,"
            msg2 = "but got #{arg_evaluated.value}"
            raise StandardError, msg1 + ' ' + msg2
          end
          to_skm(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'length', unary, primitive)
      end

      def create_newline(aRuntime)
        primitive = ->(runtime) do
          # @TODO: make output stream configurable
          print "\n"
        end

        define_primitive_proc(aRuntime, 'newline', nullary, primitive)
      end

      def create_debug(aRuntime)
        primitive = ->(runtime) do
          require 'debug'
        end

        define_primitive_proc(aRuntime, 'debug', nullary, primitive)
      end


      def def_procedure(aRuntime, pairs)
        pairs.each_slice(2) do |(name, code)|
          func = PrimitiveProcedure.new(name, code)
          define(aRuntime, func.identifier, func)
        end
      end
      
      def define_primitive_proc(aRuntime, anIdentifier, anArity, aRubyLambda)
        primitive = PrimitiveProcedure.new(anIdentifier, anArity, aRubyLambda)
        define(aRuntime, primitive.identifier, primitive)
      end

      def define(aRuntime, aKey, anEntry)
        aRuntime.define(aKey, anEntry)
      end
      
      def evaluate_array(anArray, aRuntime)
        anArray.map { |elem| elem.evaluate(aRuntime) }
      end      
      
      def evaluate_tail(anArray, aRuntime)
        evaluate_array(anArray.drop(1), aRuntime)
      end      
    end # module
  end # module
end # module