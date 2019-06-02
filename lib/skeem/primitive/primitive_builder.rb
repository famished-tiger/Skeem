require_relative 'primitive_procedure'
require_relative '../datum_dsl'
require_relative '../skm_pair'
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
        add_control_procedures(aRuntime)
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

      def one_or_two
        SkmArity.new(1, 2)
      end

      def one_or_more
        SkmArity.new(1, '*')
      end

      def add_binding(aRuntime)
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
        create_eq?(aRuntime)
        create_equal?(aRuntime)
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
        create_symbol2string(aRuntime)
      end

      def add_list_procedures(aRuntime)
        create_object_predicate(aRuntime, 'list?')
        create_object_predicate(aRuntime, 'null?')
        create_object_predicate(aRuntime, 'pair?')
        create_cons(aRuntime)
        create_car(aRuntime)
        create_cdr(aRuntime)
        create_length(aRuntime)
        create_list2vector(aRuntime)
        create_append(aRuntime)
        create_setcar(aRuntime)
        create_setcdr(aRuntime)
        create_assq(aRuntime)
        create_assv(aRuntime)
        create_list_copy(aRuntime)
      end

      def add_vector_procedures(aRuntime)
        create_object_predicate(aRuntime, 'vector?')
        create_vector(aRuntime)
        create_vector_length(aRuntime)
        create_make_vector(aRuntime)
        create_vector_ref(aRuntime)
        create_vector2list(aRuntime)
      end

      def add_control_procedures(aRuntime)
        create_object_predicate(aRuntime, 'procedure?')
        create_apply(aRuntime)
        create_map(aRuntime)
      end

      def add_io_procedures(aRuntime)(aRuntime)
        create_newline(aRuntime)
      end

      def add_special_procedures(aRuntime)
        create_test_assert(aRuntime)
        create_debug(aRuntime)
        create_inspect(aRuntime)
      end

      def create_plus(aRuntime)
        # arglist should be a Ruby Array
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            integer(0)
          else
            first_one = arglist.first.evaluate(runtime)
            raw_result = first_one.value
            operands = remaining_args(arglist, runtime)
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
            operands = arglist.evaluate(runtime).to_a
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
            operands = remaining_args(arglist, runtime)
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
            operands = arglist.evaluate(runtime).to_a
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

      def core_eqv?(eval_arg1, eval_arg2)
        raw_result = eval_arg1.eqv?(eval_arg2)
        boolean(raw_result)
      end

      def create_eqv?(aRuntime)
        primitive = ->(runtime, argument1, argument2) do
          operand_1 = argument1.evaluate(runtime)
          operand_2 = argument2.evaluate(runtime)
          core_eqv?(operand_1, operand_2)
        end

        define_primitive_proc(aRuntime, 'eqv?', binary, primitive)
      end

      def core_eq?(eval_arg1, eval_arg2)
        raw_result = eval_arg1.skm_eq?(eval_arg2)
        boolean(raw_result)
      end

      def create_eq?(aRuntime)
        primitive = ->(runtime, argument1, argument2) do
          operand_1 = argument1.evaluate(runtime)
          operand_2 = argument2.evaluate(runtime)
          core_eq?(operand1, operand2)
        end

        define_primitive_proc(aRuntime, 'eq?', binary, primitive)
      end

      def create_equal?(aRuntime)
        primitive = ->(runtime, argument1, argument2) do
          operand_1 = argument1.evaluate(runtime)
          operand_2 = argument2.evaluate(runtime)
          raw_result = operand_1.skm_equal?(operand_2)
          boolean(raw_result)
        end

        define_primitive_proc(aRuntime, 'equal?', binary, primitive)
      end

      def create_equal(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          first_one = first_operand.evaluate(runtime)
          if arglist.empty?
            boolean(true)
          else
            operands = arglist.evaluate(runtime).to_a
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
            operands.concat(arglist.evaluate(runtime).to_a)
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
            operands.concat(arglist.evaluate(runtime).to_a)
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
            operands.concat(arglist.evaluate(runtime).to_a)
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
            operands.concat(arglist.evaluate(runtime).to_a)
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
            # $stderr.puts arglist.inspect
            arglist.each do |raw_arg|
              argument = raw_arg.evaluate(aRuntime)
              last_result = argument
              raw_result &&= !(argument.boolean? && !argument.value)
              break unless raw_result # stop here, a false was found...
            end
            raw_result = last_result if raw_result
            # $stderr.puts raw_result.inspect
            # $stderr.puts raw_result.cdr.inspect if raw_result.kind_of?(SkmPair)
            # $stderr.puts to_datum(raw_result).inspect
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
              break if raw_result # stop here, a true was found...
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
            operands = evaluate_arguments(arglist, runtime)
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
            parts = evaluate_arguments(arglist, aRuntime)
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

      def create_symbol2string(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmIdentifier, 'symbol', 'symbol->string')
          string(arg_evaluated)
        end

        define_primitive_proc(aRuntime, 'symbol->string', unary, primitive)
      end

      def create_car(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmPair, 'pair', 'car')
          arg_evaluated.car
        end

        define_primitive_proc(aRuntime, 'car', unary, primitive)
      end

      def create_cdr(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmPair, 'pair', 'cdr')
          arg_evaluated.cdr
        end

        define_primitive_proc(aRuntime, 'cdr', unary, primitive)
      end

      def create_cons(aRuntime)
        primitive = ->(runtime, obj1, obj2) do
          SkmPair.new(obj1.evaluate(aRuntime), obj2.evaluate(aRuntime))
        end

        define_primitive_proc(aRuntime, 'cons', binary, primitive)
      end

      def create_length(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'length', unary, primitive)
      end

      def create_list2vector(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'list->vector')
          vector(arg_evaluated.to_a)
        end

        define_primitive_proc(aRuntime, 'list->vector', unary, primitive)
      end

      def append_core(arglist)
        if arglist.empty?
          result = SkmEmptyList.instance
        elsif arglist.size == 1
          result = arglist[0]
        else
          but_last = arglist.take(arglist.length - 1)
          check_arguments(but_last, [SkmPair, SkmEmptyList], 'list', 'append')
          result = arglist.shift.klone  # First list is taken
          arglist.each do |arg|
            case arg
              when SkmPair
                cloned = arg.klone
                if result.kind_of?(SkmEmptyList)
                  result = cloned
                else
                  if result.kind_of?(SkmEmptyList)
                    result = SkmPair.new(arg, SkmEmptyList.instance)
                  else
                    result.append_list(cloned)
                  end
                end
              when SkmEmptyList
                # Do nothing
              else
                if result.kind_of?(SkmEmptyList)
                  result = arg
                else
                  result.append(arg)
                end
            end
          end
        end

        result
      end

      def create_append(aRuntime)
        primitive = ->(runtime, arglist) do
          if arglist.size > 1
            arguments = evaluate_arguments(arglist, aRuntime)
          else
            arguments = arglist
          end

          append_core(arguments)
        end

        define_primitive_proc(aRuntime, 'append', zero_or_more, primitive)
      end

      def create_setcar(aRuntime)
        primitive = ->(runtime, pair_arg, obj_arg) do
          case pair_arg
            when SkmPair
              pair = pair_arg
            when SkmVariableReference
              found = runtime.fetch(pair_arg).expression
              case found
                when SkmPair
                  pair = found
                when ProcedureCall
                  pair = found.evaluate(aRuntime)
              end
            else
              pair = pair_arg.evaluate(runtime)
          end
          check_argtype(pair, SkmPair, 'pair', 'set-car!')
          obj = obj_arg.evaluate(runtime)
          pair.car = obj
        end

        define_primitive_proc(aRuntime, 'set-car!', binary, primitive)
      end

      def create_setcdr(aRuntime)
        primitive = ->(runtime, pair_arg, obj_arg) do
          case pair_arg
            when SkmPair
              pair = pair_arg
            when SkmVariableReference
              found = runtime.fetch(pair_arg).expression
              case found
                when SkmPair
                  pair = found
                when ProcedureCall
                  pair = found.evaluate(aRuntime)
              end
            else
              pair = pair_arg.evaluate(runtime)
          end
          check_argtype(pair, SkmPair, 'pair', 'set-cdr!')
          obj = obj_arg.evaluate(runtime)
          pair.cdr = obj
        end

        define_primitive_proc(aRuntime, 'set-cdr!', binary, primitive)
      end

      def create_assq(aRuntime)
        primitive = ->(runtime, obj_arg, alist_arg) do
          assoc_list = alist_arg.evaluate(runtime)
          check_assoc_list(assoc_list, 'assq')
          obj = obj_arg.evaluate(runtime)          
          result = boolean(false)
          unless assoc_list.empty?
            pair = assoc_list
            begin
              are_equal = core_eq?(pair.car.car, obj)
              if are_equal.value
                result = pair.car
                break
              end
              pair = pair.cdr
            end while (pair && (pair.kind_of?(SkmPair)))
          end

          result
        end
        define_primitive_proc(aRuntime, 'assq', binary, primitive)
      end
      
      def create_assv(aRuntime)
        primitive = ->(runtime, obj_arg, alist_arg) do
          assoc_list = alist_arg.evaluate(runtime)
          check_assoc_list(assoc_list, 'assq')
          obj = obj_arg.evaluate(runtime)          
          result = boolean(false)
          unless assoc_list.empty?
            pair = assoc_list
            begin
              are_equal = core_eqv?(pair.car.car, obj)
              if are_equal.value
                result = pair.car
                break
              end
              pair = pair.cdr
            end while (pair && (pair.kind_of?(SkmPair)))
          end

          result
        end
        define_primitive_proc(aRuntime, 'assv', binary, primitive)      
      end      

      def check_assoc_list(alist, proc_name)
        check_argtype(alist, [SkmPair, SkmEmptyList], 'association list', proc_name)

        unless alist.empty?
          cell = SkmPair.new(integer(1), alist)
          begin
            cell = cell.cdr
            check_argtype(cell, SkmPair, 'association list', proc_name)
          end while cell.cdr.kind_of?(SkmPair)
        end
      end

      def create_list_copy(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'list-copy')
          arg.klone
        end

        define_primitive_proc(aRuntime, 'list-copy', unary, primitive)
      end


      def create_vector(aRuntime)
        primitive = ->(runtime, arglist) do
          if arglist.empty?
            elements = []
          else
            elements = evaluate_arguments(arglist, aRuntime)
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

      def create_make_vector(aRuntime)
        primitive = ->(runtime, count_arg, arglist) do
          count = count_arg.evaluate(runtime)
          check_argtype(count, SkmInteger, 'integer', 'make_vector')
          if arglist.empty?
            filler = SkmUndefined.instance
          else
            filler = arglist.car.evaluate(runtime)
          end
          elements = Array.new(count.value, filler)

          vector(elements)
        end

        define_primitive_proc(aRuntime, 'make-vector', one_or_two, primitive)
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

      def create_vector2list(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          check_argtype(arg_evaluated, SkmVector, 'vector', 'vector->list')
          SkmPair.create_from_a(arg_evaluated.members)
        end

        define_primitive_proc(aRuntime, 'vector->list', unary, primitive)
      end

      def create_apply(aRuntime)
        primitive = ->(runtime, first_operand, arglist) do
          proc_arg = first_operand.evaluate(runtime)
          if arglist.empty?
            result = SkmEmptyList.instance
          else
            arguments = evaluate_arguments(arglist, runtime)
            single_list = append_core(arguments)
            invoke = ProcedureCall.new(nil, proc_arg, single_list.to_a)
            result = invoke.evaluate(runtime)
          end
        end

        define_primitive_proc(aRuntime, 'apply', one_or_more, primitive)
      end

      def create_map(aRuntime)
        primitive = ->(runtime, first_operand, list_of_lists) do
          proc_arg = first_operand.evaluate(runtime)
          if list_of_lists.empty?
            result = SkmEmptyList.instance
          else
            arguments = evaluate_arguments(list_of_lists, runtime)
            curr_cells = arguments.to_a
            arity = curr_cells.size
            initial_result = nil
            curr_result = nil
            loop do
              call_args = curr_cells.map(&:car)
              invoke = ProcedureCall.new(nil, proc_arg, call_args)
              call_result = invoke.evaluate(runtime)
              new_result = SkmPair.new(call_result, SkmEmptyList.instance)
              if initial_result
                curr_result.cdr = new_result
              else
                initial_result = new_result
              end
              curr_result = new_result

              curr_cells.map!(&:cdr)
              break if curr_cells.find { |cdr_entry| ! cdr_entry.kind_of?(SkmPair) }
            end

            result = initial_result
          end

          result
        end

        define_primitive_proc(aRuntime, 'map', one_or_more, primitive)
      end

      def create_newline(aRuntime)
        primitive = ->(runtime) do
          # @TODO: make output stream configurable
          print "\n"
        end

        define_primitive_proc(aRuntime, 'newline', nullary, primitive)
      end

      def create_test_assert(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          if arg_evaluated.boolean? && arg_evaluated.value == false
            assert_call = aRuntime.caller
            pos = assert_call.call_site
            # Error: assertion failed: (> 1 2)
            msg1 = "assertion failed on line #{pos.line}, column #{pos.column}"
            msg2 = ", with #{arg.inspect}"
            raise StandardError, 'Error: ' + msg1 + msg2
          else
            boolean(true)
          end
        end

        define_primitive_proc(aRuntime, 'test-assert', unary, primitive)
      end

      # DON'T USE IT
      # Non-standard procedure reserved for internal testing/debugging purposes.
      def create_debug(aRuntime)
        primitive = ->(runtime) do
          require 'debug'
        end

        define_primitive_proc(aRuntime, 'debug', nullary, primitive)
      end

      # DON'T USE IT
      # Non-standard procedure reserved for internal testing/debugging purposes.
      def create_inspect(aRuntime)
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          $stderr.puts 'INSPECT>' + arg_evaluated.inspect
          Skeem::SkmUndefined.instance
        end
        define_primitive_proc(aRuntime, '_inspect', unary, primitive)
      end

      def create_object_predicate(aRuntime, predicate_name, msg_name = nil)
        msg_name = predicate_name if msg_name.nil?
        primitive = ->(runtime, arg) do
          arg_evaluated = arg.evaluate(runtime)
          to_datum(arg_evaluated.send(msg_name))
        end

        define_primitive_proc(aRuntime, predicate_name, unary, primitive)
      end

      # def def_procedure(aRuntime, pairs)
        # pairs.each_slice(2) do |(name, code)|
          # func = PrimitiveProcedure.new(name, code)
          # define(aRuntime, func.identifier, func)
        # end
      # end

      def define_primitive_proc(aRuntime, anIdentifier, anArity, aRubyLambda)
        primitive = PrimitiveProcedure.new(anIdentifier, anArity, aRubyLambda)
        @primitive_map = {} unless @primitives_map
        @primitive_map[primitive.identifier] = primitive.code
        define(aRuntime, primitive.identifier, primitive)
      end

      def define(aRuntime, aKey, anEntry)
        aRuntime.add_binding(aKey, anEntry)
      end

      def evaluate_arguments(arglist, aRuntime)
        case arglist
        when Array
          arglist.map { |elem| elem.evaluate(aRuntime) }
        when SkmPair
          arglist.evaluate(aRuntime).to_a
        end
      end

      def check_arguments(arguments, requiredRubyClass, requiredSkmType, aProcName)
        arguments.each do |argument|
          if requiredRubyClass.kind_of?(Array)
            unless requiredRubyClass.include?(argument.class)
              type_error(argument, requiredSkmType, aProcName)
            end
          else
            unless argument.kind_of?(requiredRubyClass)
              type_error(argument, requiredSkmType, aProcName)
            end
          end
        end
      end

      def check_argtype(argument, requiredRubyClass, requiredSkmType, aProcName)
        if requiredRubyClass.kind_of?(Array)
          unless requiredRubyClass.include?(argument.class)
            type_error(argument, requiredSkmType, aProcName)
          end
        else
          unless argument.kind_of?(requiredRubyClass)
            type_error(argument, requiredSkmType, aProcName)
          end
        end
      end

      def type_error(argument, requiredSkmType, aProcName)
        msg1 = "Procedure '#{aProcName}': #{requiredSkmType} argument required,"
        if argument.respond_to?(:value)
          msg2 = "but got #{argument.value}"
        else
          msg2 = "but got #{argument.class}"
        end
        raise StandardError, msg1 + ' ' + msg2
      end

      def remaining_args(arglist, aRuntime)
        case arglist
        when Array
          raw_arg = arglist[1..-1]
        when SkmPair
          raw_arg = arglist.cdr.to_a
        end
        raw_arg.map { |arg| arg.evaluate(aRuntime) }
      end
    end # module
  end # module
end # module