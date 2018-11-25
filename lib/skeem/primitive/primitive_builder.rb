require_relative 'primitive_procedure'
require_relative '../datum_dsl'
# require_relative '../s_expr_nodes'

module Skeem
  module Primitive
    module PrimitiveBuilder
      include DatumDSL
      def add_primitives(aRuntime)
        add_binding(aRuntime)
        add_arithmetic(aRuntime)
        add_comparison(aRuntime)
        add_number_procedures(aRuntime)
        add_boolean_procedures(aRuntime)
        add_string_procedures(aRuntime)
        add_symbol_procedures(aRuntime)
        add_list_procedures(aRuntime)
        add_vector_procedures(aRuntime)
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

      def add_binding(aRuntime)
        create_set!(aRuntime)
      end

      def add_arithmetic(aRuntime)
        create_plus(aRuntime)
        create_minus(aRuntime)
        create_multiply(aRuntime)
        create_divide(aRuntime)
        create_modulo(aRuntime)
      end

      def add_comparison(aRuntime)
        create_eqv?(aRuntime)
        create_equal(aRuntime)
        create_lt(aRuntime)
        create_gt(aRuntime)
        create_lte(aRuntime)
        create_gte(aRuntime)
      end

      def add_number_procedures(aRuntime)
        create_object_predicate(aRuntime, 'number?')
        create_object_predicate(aRuntime, 'real?')
        create_object_predicate(aRuntime, 'integer?')
        create_object_predicate(aRuntime, 'exact?')
        create_number2string(aRuntime)
      end

      def add_boolean_procedures(aRuntime)
        create_and(aRuntime)
        create_or(aRuntime)
        create_object_predicate(aRuntime, 'boolean?')
      end

      def add_string_procedures(aRuntime)
        create_object_predicate(aRuntime, 'string?')
        create_string_equal(aRuntime)
        create_string_append(aRuntime)
        create_string_length(aRuntime)
        create_string2symbol(aRuntime)
      end

      def add_symbol_procedures(aRuntime)
        create_object_predicate(aRuntime, 'symbol?')
      end

      def add_list_procedures(aRuntime)
        create_object_predicate(aRuntime, 'list?')
        create_object_predicate(aRuntime, 'null?')
        create_length(aRuntime)
      end

      def add_vector_procedures(aRuntime)
        create_object_predicate(aRuntime, 'vector?')
        create_vector(aRuntime)
        create_vector_length(aRuntime)
        create_vector_ref(aRuntime)
      end

      def add_io_procedures(aRuntime)(aRuntime)
        create_newline(aRuntime)
      end

      def add_special_procedures(aRuntime)
        create_assert(aRuntime)
        create_debug(aRuntime)
      end

      def create_set!(aRuntime)
          primitive = ->(runtime, var_ref, expr) do
            if runtime.include?(var_ref.child)
              redefinition = SkmDefinition.new(nil, var_ref.child, expr)
              redefinition.evaluate(runtime)
            else
              raise StandardError, "Unbound variable: '#{var.value}'"
            end
        end

        define_primitive_proc(aRuntime, 'set!', binary, primitive)
      end

      def create_plus(aRuntime)
        # arglist should be a Ruby Array
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            integer(0)
          else
            first_one = arglist.first.evaluate(runtime)
            raw_result = first_one.value
            operands = evaluate_tail(arglist, runtime)
            operands.each { |elem| raw_result += elem.value }
            to_datum(raw_result)
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
          to_datum(raw_result)
        end

        define_primitive_proc(aRuntime, '-', one_or_more, primitive)
      end

      def create_multiply(aRuntime)
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            integer(1)
          else
            first_one = arglist.first.evaluate(runtime)
            raw_result = first_one.value
            operands = evaluate_tail(arglist, runtime)
            operands.each { |elem| raw_result *= elem.value }
            to_datum(raw_result)
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
          to_datum(raw_result)
        end

        define_primitive_proc(aRuntime, '/', one_or_more, primitive)
      end

      def create_modulo(aRuntime)
        primitive = ->(runtime, argument1, argument2) do
          operand_1 = argument1.evaluate(runtime)
          operand_2 = argument2.evaluate(runtime)
          raw_result = operand_1.value.modulo(operand_2.value)
          to_datum(raw_result)
        end

        define_primitive_proc(aRuntime, 'floor-remainder', binary, primitive)
      end
      
      def create_eqv?(aRuntime)
        primitive = ->(runtime, argument1, argument2) do
          operand_1 = argument1.evaluate(runtime)
          operand_2 = argument2.evaluate(runtime)
          raw_result = operand_1.eqv?(operand_2)
          to_datum(raw_result)
        end

        define_primitive_proc(aRuntime, 'eqv?', binary, primitive)      
      end

      def create_equal(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          first_one = first_operand.evaluate(runtime)
          if arglist.empty?
            boolean(true)
          else
            operands = evaluate_array(arglist, runtime)
            first_value = first_one.value
            all_equal = operands.all? { |elem| first_value == elem.value }
            boolean(all_equal)
          end
        end

        define_primitive_proc(aRuntime, '=', one_or_more, primitive)
      end

      def create_lt(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            boolean(false)
          else
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value < elem2.value
            end
            boolean(result)
          end
        end

        define_primitive_proc(aRuntime, '<', one_or_more, primitive)
      end

      def create_gt(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            boolean(false)
          else
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value > elem2.value
            end
            boolean(result)
          end
        end

        define_primitive_proc(aRuntime, '>', one_or_more, primitive)
      end

      def create_lte(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            boolean(true)
          else
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value <= elem2.value
            end
            boolean(result)
          end
        end

        define_primitive_proc(aRuntime, '<=', one_or_more, primitive)
      end

      def create_gte(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          if arglist.empty?
            boolean(true)
          else
            operands = [first_operand.evaluate(runtime)]
            operands.concat(evaluate_array(arglist, runtime))
            result = true
            operands.each_cons(2) do |(elem1, elem2)|
              result &&= elem1.value >= elem2.value
            end
            boolean(result)
          end
        end

        define_primitive_proc(aRuntime, '>=', one_or_more, primitive)
      end

      def create_number2string(aRuntime)
        # TODO: add support for radix argument
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmNumber, 'number', 'number->string')
          string(arg_evaluated.value)
        end

        define_primitive_proc(aRuntime, 'number->string', unary, primitive)
      end

      def create_and(aRuntime)
        # arglist should be a Ruby Array
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            boolean(true) # in conformance with 4.2.1
          else
            raw_result = true
            last_result = nil
            arglist.each do |raw_arg|
              argument = raw_arg.evaluate(aRuntime)
              last_result = argument
              raw_result &&= !(argument.boolean? && !argument.value)
              break unless raw_result
            end
            raw_result = last_result if raw_result
            to_datum(raw_result)
          end
        end
        define_primitive_proc(aRuntime, 'and', zero_or_more, primitive)
      end

      def create_or(aRuntime)
        # arglist should be a Ruby Array
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            boolean(false) # in conformance with 4.2.1
          else
            raw_result = false
            last_result = nil
            arglist.each do |raw_arg|
              argument = raw_arg.evaluate(aRuntime)
              last_result = argument
              raw_result ||= (!argument.boolean? || argument.value)
              break if raw_result
            end
            raw_result = last_result if raw_result
            to_datum(raw_result)
          end
        end
        define_primitive_proc(aRuntime, 'or', zero_or_more, primitive)
      end

      def create_string_equal(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          first_one = first_operand.evaluate(runtime)
          if arglist.empty?
            boolean(true)
          else
            operands = evaluate_array(arglist, runtime)
            first_value = first_one.value
            all_equal = operands.all? { |elem| first_value == elem.value }
            boolean(all_equal)
          end
        end

        define_primitive_proc(aRuntime, 'string=?', one_or_more, primitive)
      end

      def create_string_append(aRuntime)
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            value = ''
          else
            parts = evaluate_array(arglist, aRuntime)
            value = parts.reduce('') { |interim, substr| interim << substr.value }
          end

          string(value)
        end

        define_primitive_proc(aRuntime, 'string-append', zero_or_more, primitive)
      end

      def create_string_length(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmString, 'string', 'string-length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'string-length', unary, primitive)
      end

      def create_string2symbol(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmString, 'string', 'string->symbol')
          identifier(arg_evaluated)
        end

        define_primitive_proc(aRuntime, 'string->symbol', unary, primitive)
      end

      def create_length(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmList, 'list', 'length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'length', unary, primitive)
      end

      def create_vector(aRuntime)
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            elements = []
          else
            elements = evaluate_array(arglist, aRuntime)
          end

          vector(elements)
        end

        define_primitive_proc(aRuntime, 'vector', zero_or_more, primitive)
      end

      def create_vector_length(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmVector, 'vector', 'vector-length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'vector-length', unary, primitive)
      end

      def create_vector_ref(aRuntime)
          # argument 1: a vector, argument 2: an index(integer)
          primitive = ->(runtime, aVector, anIndex) do
          vector = aVector.evaluate(runtime)
          check_argtype(vector, SkmVector, 'vector', 'vector-ref')
          index = anIndex.evaluate(runtime)
          check_argtype(index, SkmInteger, 'integer', 'vector-ref')
          # TODO: index checking
          raw_result = vector.members[index.value]
          to_datum(raw_result) # What if non-datum result?
        end

        define_primitive_proc(aRuntime, 'vector-ref', binary, primitive)
      end

      def create_newline(aRuntime)
        primitive = ->(runtime) do
          # @TODO: make output stream configurable
          print "\n"
        end

        define_primitive_proc(aRuntime, 'newline', nullary, primitive)
      end
      
      def create_assert(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          if arg_evaluated.boolean? && arg_evaluated.value == false
            assert_call = aRuntime.caller
            pos = assert_call.call_site          
            # Error: assertion failed: (> 1 2)
            msg = "assertion failed on line #{pos.line}, column #{pos.column}"
            raise StandardError, 'Error: ' + msg
          else
            boolean(true)
          end
        end

        define_primitive_proc(aRuntime, 'assert', unary, primitive)
      end

      def create_debug(aRuntime)
        primitive = ->(runtime) do
          require 'debug'
        end

        define_primitive_proc(aRuntime, 'debug', nullary, primitive)
      end

      def create_object_predicate(aRuntime, predicate_name, msg_name = nil)
        msg_name = predicate_name if msg_name.nil?
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_datum(arg_evaluated.send(msg_name))
        end

        define_primitive_proc(aRuntime, predicate_name, unary, primitive)
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

      def check_argtype(argument, requiredRubyClass, requiredSkmType, aProcName)
          unless argument.kind_of?(requiredRubyClass)
            msg1 = "Procedure '#{aProcName}': #{requiredSkmType} argument required,"
            msg2 = "but got #{argument.value}"
            raise StandardError, msg1 + ' ' + msg2
          end
      end
    end # module
  end # module
end # module