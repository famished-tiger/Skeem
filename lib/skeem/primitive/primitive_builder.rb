require_relative 'primitive_procedure'
require_relative '../datum_dsl'
require_relative '../skm_pair'

module Skeem
  module Primitive
    module PrimitiveBuilder
      include DatumDSL
      def add_primitives(aRuntime)
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

      def add_arithmetic(aRuntime)
        create_plus(aRuntime)
        create_minus(aRuntime)
        create_multiply(aRuntime)
        create_divide(aRuntime)
        create_floor_slash(aRuntime)
        create_truncate_slash(aRuntime)
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
        create_max(aRuntime)
        create_min(aRuntime)
      end

      def add_number_procedures(aRuntime)
        create_object_predicate(aRuntime, 'number?')
        create_object_predicate(aRuntime, 'complex?')
        create_object_predicate(aRuntime, 'real?')
        create_object_predicate(aRuntime, 'rational?')
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
        primitive = ->(_runtime, arglist) do
          if arglist.empty?
            integer(0)
          else
            first_one = arglist.shift
            raw_result = first_one.value
            arglist.each { |elem| raw_result += elem.value }
            to_datum(raw_result)
          end
        end
        define_primitive_proc(aRuntime, '+', zero_or_more, primitive)
      end

      def create_minus(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          raw_result = first_operand.value
          if arglist.empty?
            raw_result = -raw_result
          else
            arglist.each { |elem| raw_result -= elem.value }
          end
          to_datum(raw_result)
        end

        define_primitive_proc(aRuntime, '-', one_or_more, primitive)
      end

      def create_multiply(aRuntime)
        primitive = ->(_runtime, arglist) do
          if arglist.empty?
            integer(1)
          else
            first_one = arglist.shift
            raw_result = first_one.value
            arglist.each { |elem| raw_result *= elem.value }
            to_datum(raw_result)
          end
        end
        define_primitive_proc(aRuntime, '*', zero_or_more, primitive)
      end

      def reciprocal(aLiteral)

        case aLiteral
          when Integer
            result = Rational(1, aLiteral)
          when Rational
            result = Rational(aLiteral.denominator, aLiteral.numerator)
          else
            result = 1 / aLiteral.to_f
        end

        result
      end

      def create_divide(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          raw_result = first_operand.value
          if arglist.empty?
            raw_result = reciprocal(raw_result)
          else
            arglist.each do |elem|
              elem_value = elem.value
              case [raw_result.class, elem_value.class]
                when [Integer, Integer]
                  if raw_result.modulo(elem_value).zero?
                    raw_result = raw_result / elem_value
                  else
                    raw_result = Rational(raw_result, elem_value)
                  end

                when [Integer, Rational]
                  raw_result = raw_result * reciprocal(elem_value)

                when [Rational, Rational]
                  raw_result = raw_result * reciprocal(elem_value)
                else
                  raw_result = raw_result.to_f
                  raw_result /= elem_value
              end
            end
          end
          to_datum(raw_result)
        end

        define_primitive_proc(aRuntime, '/', one_or_more, primitive)
      end
      
      def create_floor_slash(aRuntime)
        primitive = ->(_runtime, operand_1, operand_2) do
          (quotient, modulus) = operand_1.value.divmod(operand_2.value)
          SkmPair.new(to_datum(quotient), to_datum(modulus)) # improper list!
        end

        define_primitive_proc(aRuntime, 'floor/', binary, primitive)      
      end      

      def create_truncate_slash(aRuntime)
        primitive = ->(_runtime, operand_1, operand_2) do
          modulo_ = operand_1.value / operand_2.value
          modulo_ += 1 if modulo_ < 0
          remainder_ = operand_1.value.remainder(operand_2.value)
          SkmPair.new(to_datum(modulo_), to_datum(remainder_)) # improper list!
        end

        define_primitive_proc(aRuntime, 'truncate/', binary, primitive)
      end

      def core_eqv?(eval_arg1, eval_arg2)
        raw_result = eval_arg1.eqv?(eval_arg2)
        boolean(raw_result)
      end

      def create_eqv?(aRuntime)
        primitive = ->(runtime, operand_1, operand_2) do
          core_eqv?(operand_1, operand_2)
        end

        define_primitive_proc(aRuntime, 'eqv?', binary, primitive)
      end

      def core_eq?(eval_arg1, eval_arg2)
        raw_result = eval_arg1.skm_eq?(eval_arg2)
        boolean(raw_result)
      end

      def create_eq?(aRuntime)
        primitive = ->(_runtime, operand_1, operand_2) do
          core_eq?(operand1, operand2)
        end

        define_primitive_proc(aRuntime, 'eq?', binary, primitive)
      end

      def create_equal?(aRuntime)
        primitive = ->(_runtime, operand_1, operand_2) do
          raw_result = operand_1.skm_equal?(operand_2)
          boolean(raw_result)
        end

        define_primitive_proc(aRuntime, 'equal?', binary, primitive)
      end

      def create_equal(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            boolean(true)
          else
            first_value = first_operand.value
            all_equal = arglist.all? { |elem| first_value == elem.value }
            boolean(all_equal)
          end
        end

        define_primitive_proc(aRuntime, '=', one_or_more, primitive)
      end

      def create_lt(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            result = false
          else
            result = primitive_comparison(:<, _runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '<', one_or_more, primitive)
      end

      def create_gt(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            result = false
          else
            result = primitive_comparison(:>, _runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '>', one_or_more, primitive)
      end

      def create_lte(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            result = true
          else
            result = primitive_comparison(:<=, _runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '<=', one_or_more, primitive)
      end

      def create_gte(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            result = true
          else
            result = primitive_comparison(:>=, _runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '>=', one_or_more, primitive)
      end

      def primitive_comparison(operator, _runtime, first_operand, arglist)
        operands = [first_operand].concat(arglist)
        result = true
        operands.each_cons(2) do |(elem1, elem2)|
          result &&= elem1.value.send(operator, elem2.value)
        end

        boolean(result)
      end

      def create_max(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            result = first_operand
          else
            arr = arglist.to_a
            arr.prepend(first_operand)
            result = arr.max do |a, b|
              a.value <=> b.value if a.real? && b.real?
            end
          end

          result
        end

        define_primitive_proc(aRuntime, 'max', one_or_more, primitive)
      end

      def create_min(aRuntime)
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            result = first_operand
          else
            arr = arglist.to_a
            arr.prepend(first_operand)
            result = arr.min do |a, b|
              a.value <=> b.value if a.real? && b.real?
            end
          end

          result
        end

        define_primitive_proc(aRuntime, 'min', one_or_more, primitive)
      end

      def create_number2string(aRuntime)
        # TODO: add support for radix argument
        primitive = ->(_runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmNumber, 'number', 'number->string')
          string(arg_evaluated.value)
        end

        define_primitive_proc(aRuntime, 'number->string', unary, primitive)
      end

      def create_and(aRuntime)
        # arglist should be a Ruby Array
        # Arguments aren't evaluated yet!...
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
        # Arguments aren't evaluated yet!...
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
        primitive = ->(_runtime, first_operand, arglist) do
          if arglist.empty?
            boolean(true)
          else
            first_value = first_operand.value
            all_equal = arglist.all? { |elem| first_value == elem.value }
            boolean(all_equal)
          end
        end

        define_primitive_proc(aRuntime, 'string=?', one_or_more, primitive)
      end

      def create_string_append(aRuntime)
        primitive = ->(_runtime, arglist) do
          if arglist.empty?
            value = ''
          else
            value = arglist.reduce('') { |interim, substr| interim << substr.value }
          end

          string(value)
        end

        define_primitive_proc(aRuntime, 'string-append', zero_or_more, primitive)
      end

      def create_string_length(aRuntime)
        primitive = ->(runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmString, 'string', 'string-length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'string-length', unary, primitive)
      end

      def create_string2symbol(aRuntime)
        primitive = ->(runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmString, 'string', 'string->symbol')
          identifier(arg_evaluated)
        end

        define_primitive_proc(aRuntime, 'string->symbol', unary, primitive)
      end

      def create_symbol2string(aRuntime)
        primitive = ->(runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmIdentifier, 'symbol', 'symbol->string')
          string(arg_evaluated)
        end

        define_primitive_proc(aRuntime, 'symbol->string', unary, primitive)
      end

      def create_car(aRuntime)
        primitive = ->(runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmPair, 'pair', 'car')
          arg_evaluated.car
        end

        define_primitive_proc(aRuntime, 'car', unary, primitive)
      end

      def create_cdr(aRuntime)
        primitive = ->(_runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmPair, 'pair', 'cdr')
          arg_evaluated.cdr
        end

        define_primitive_proc(aRuntime, 'cdr', unary, primitive)
      end

      def create_cons(aRuntime)
        primitive = ->(_runtime, obj1, obj2) do
          SkmPair.new(obj1, obj2)
        end

        define_primitive_proc(aRuntime, 'cons', binary, primitive)
      end

      def create_length(aRuntime)
        primitive = ->(_runtime, arg_evaluated) do
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'length', unary, primitive)
      end

      def create_list2vector(aRuntime)
        primitive = ->(_runtime, arg_evaluated) do
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
        # Arguments aren't evaluated yet!...
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
        # Arguments aren't evaluated yet!...
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
        # Arguments aren't evaluated yet!...
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
        primitive = ->(runtime, obj, assoc_list) do
          check_assoc_list(assoc_list, 'assq')
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
        primitive = ->(runtime, arg_evaluated) do
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'list-copy')
          arg_evaluated.klone # Previously: arg.klone
        end

        define_primitive_proc(aRuntime, 'list-copy', unary, primitive)
      end

      def create_vector(aRuntime)
        primitive = ->(_runtime, elements) do
          vector(elements)
        end

        define_primitive_proc(aRuntime, 'vector', zero_or_more, primitive)
      end

      def create_vector_length(aRuntime)
        primitive = ->(_runtime, arg_evaluated) do
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
            filler = arglist.first.evaluate(runtime)
          end
          elements = Array.new(count.value, filler)

          vector(elements)
        end

        define_primitive_proc(aRuntime, 'make-vector', one_or_two, primitive)
      end

      def create_vector_ref(aRuntime)
          # argument 1: a vector, argument 2: an index(integer)
          primitive = ->(runtime, vector, index) do
          check_argtype(vector, SkmVector, 'vector', 'vector-ref')
          check_argtype(index, SkmInteger, 'integer', 'vector-ref')
          # TODO: index checking
          raw_result = vector.members[index.value]
          to_datum(raw_result) # What if non-datum result?
        end

        define_primitive_proc(aRuntime, 'vector-ref', binary, primitive)
      end

      def create_vector2list(aRuntime)
        primitive = ->(runtime, arg_evaluated) do
          check_argtype(arg_evaluated, SkmVector, 'vector', 'vector->list')
          SkmPair.create_from_a(arg_evaluated.members)
        end

        define_primitive_proc(aRuntime, 'vector->list', unary, primitive)
      end

      def create_apply(aRuntime)
        primitive = ->(runtime, proc_arg, arglist) do
          if arglist.empty?
            result = SkmEmptyList.instance
          else
            single_list = append_core(arglist)
            invoke = ProcedureCall.new(nil, proc_arg, single_list.to_a)
            result = invoke.evaluate(runtime)
          end
        end

        define_primitive_proc(aRuntime, 'apply', one_or_more, primitive)
      end

      def create_map(aRuntime)
        primitive = ->(runtime, proc_arg, arglist) do
          if arglist.empty?
            result = SkmEmptyList.instance
          else
            curr_cells = arglist
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
        primitive = ->(runtime, arg_evaluated) do
          if arg_evaluated.boolean? && arg_evaluated.value == false
            assert_call = aRuntime.caller
            pos = assert_call.call_site
            # Error: assertion failed: (> 1 2)
            msg1 = "assertion failed on line #{pos.line}, column #{pos.column}"
            msg2 = ", with #{arg_evaluated.inspect}"
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
        primitive = ->(runtime, arg_evaluated) do
          $stderr.puts 'INSPECT>' + arg_evaluated.inspect
          Skeem::SkmUndefined.instance
        end
        define_primitive_proc(aRuntime, '_inspect', unary, primitive)
      end

      def create_object_predicate(aRuntime, predicate_name, msg_name = nil)
        msg_name = predicate_name if msg_name.nil?
        primitive = ->(runtime, arg_evaluated) do
          to_datum(arg_evaluated.send(msg_name))
        end

        define_primitive_proc(aRuntime, predicate_name, unary, primitive)
      end

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