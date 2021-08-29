# frozen_string_literal: true

require_relative 'primitive_procedure'
require_relative '../datum_dsl'
require_relative '../skm_exception'
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
        add_char_procedures(aRuntime)
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

      def ternary
        SkmArity.new(3, 3)
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
        create_gcd(aRuntime)
        create_lcm(aRuntime)
        create_numerator(aRuntime)
        create_denominator(aRuntime)
        create_floor(aRuntime)
        create_ceiling(aRuntime)
        create_round(aRuntime)
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
        create_boolean_equal(aRuntime)
      end

      def add_char_procedures(aRuntime)
        create_object_predicate(aRuntime, 'char?')
        create_char2int(aRuntime)
        create_int2char(aRuntime)
        create_char_equal(aRuntime)
        create_char_lt(aRuntime)
        create_char_gt(aRuntime)
        create_char_lte(aRuntime)
        create_char_gte(aRuntime)
      end

      def add_string_procedures(aRuntime)
        create_object_predicate(aRuntime, 'string?')
        create_make_string(aRuntime)
        create_string_string(aRuntime)
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
        create_make_list(aRuntime)
        create_length(aRuntime)
        create_list2vector(aRuntime)
        create_append(aRuntime)
        create_reverse(aRuntime)
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
        create_vector_set(aRuntime)
        create_vector2list(aRuntime)
      end

      def add_control_procedures(aRuntime)
        create_object_predicate(aRuntime, 'procedure?')
        create_apply(aRuntime)
        create_map(aRuntime)
      end

      def add_io_procedures(aRuntime)
        create_display(aRuntime)
      end

      def add_special_procedures(aRuntime)
        create_error(aRuntime)
        create_test_assert(aRuntime)
        create_debug(aRuntime)
        create_inspect(aRuntime)
      end

      def create_plus(aRuntime)
        # arglist should be a Ruby Array
        primitive = lambda do |_runtime, arglist|
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
        primitive = lambda do |_runtime, first_operand, arglist|
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
        primitive = lambda do |_runtime, arglist|
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
        primitive = lambda do |_runtime, first_operand, arglist|
          raw_result = first_operand.value
          if arglist.empty?
            raw_result = reciprocal(raw_result)
          else
            arglist.each do |elem|
              elem_value = elem.value
              case [raw_result.class, elem_value.class]
                when [Integer, Integer]
                  if raw_result.modulo(elem_value).zero?
                    raw_result /= elem_value
                  else
                    raw_result = Rational(raw_result, elem_value)
                  end

                when [Integer, Rational]
                  raw_result *= reciprocal(elem_value)

                when [Rational, Rational]
                  raw_result *= reciprocal(elem_value)
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
        primitive = lambda do |_runtime, operand1, operand2|
          (quotient, modulus) = operand1.value.divmod(operand2.value)
          SkmPair.new(to_datum(quotient), to_datum(modulus)) # improper list!
        end

        define_primitive_proc(aRuntime, 'floor/', binary, primitive)
      end

      def create_truncate_slash(aRuntime)
        primitive = lambda do |_runtime, operand1, operand2|
          modulo_ = operand1.value / operand2.value
          modulo_ += 1 if modulo_.negative?
          remainder_ = operand1.value.remainder(operand2.value)
          SkmPair.new(to_datum(modulo_), to_datum(remainder_)) # improper list!
        end

        define_primitive_proc(aRuntime, 'truncate/', binary, primitive)
      end

      def create_gcd(aRuntime)
        primitive = lambda do |_runtime, arglist|
          if arglist.empty?
            integer(0)
          else
            first_one = arglist.shift
            divisor = first_one.value

            arglist.each do |elem|
              divisor = divisor.gcd(elem.value)
              break if divisor == 1
            end

            to_datum(divisor)
          end
        end
        define_primitive_proc(aRuntime, 'gcd', zero_or_more, primitive)
      end

      def create_lcm(aRuntime)
        primitive = lambda do |_runtime, arglist|
          if arglist.empty?
            integer(1)
          else
            values = arglist.map(&:value)
            multiple = values.reduce(1, :lcm)

            to_datum(multiple)
          end
        end
        define_primitive_proc(aRuntime, 'lcm', zero_or_more, primitive)
      end

      def create_numerator(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          case arg_evaluated
            when SkmInteger
              result = arg_evaluated
            when SkmRational, SkmReal
              result = integer(arg_evaluated.value.numerator)
          end
          result
        end

        define_primitive_proc(aRuntime, 'numerator', unary, primitive)
      end

      def create_denominator(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          case arg_evaluated
            when SkmInteger
              result = 1
            when SkmRational, SkmReal
              result = arg_evaluated.value.denominator
          end
          integer(result)
        end

        define_primitive_proc(aRuntime, 'denominator', unary, primitive)
      end

      def create_floor(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          result = arg_evaluated.value.floor
          integer(result)
        end

        define_primitive_proc(aRuntime, 'floor', unary, primitive)
      end

      def create_ceiling(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          result = arg_evaluated.value.ceil
          integer(result)
        end

        define_primitive_proc(aRuntime, 'ceiling', unary, primitive)
      end

      def create_round(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          result = arg_evaluated.value.round
          integer(result)
        end

        define_primitive_proc(aRuntime, 'round', unary, primitive)
      end

      def core_eqv?(eval_arg1, eval_arg2)
        raw_result = eval_arg1.eqv?(eval_arg2)
        boolean(raw_result)
      end

      def create_eqv?(aRuntime)
        primitive = lambda do |_runtime, operand1, operand2|
          core_eqv?(operand1, operand2)
        end

        define_primitive_proc(aRuntime, 'eqv?', binary, primitive)
      end

      def core_eq?(eval_arg1, eval_arg2)
        raw_result = eval_arg1.skm_eq?(eval_arg2)
        boolean(raw_result)
      end

      def create_eq?(aRuntime)
        primitive = lambda do |_runtime, operand1, operand2|
          core_eq?(operand1, operand2)
        end

        define_primitive_proc(aRuntime, 'eq?', binary, primitive)
      end

      def create_equal?(aRuntime)
        primitive = lambda do |_runtime, operand1, operand2|
          raw_result = operand1.skm_equal?(operand2)
          boolean(raw_result)
        end

        define_primitive_proc(aRuntime, 'equal?', binary, primitive)
      end

      def create_equal(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
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
        primitive = lambda do |runtime, first_operand, arglist|
          if arglist.empty?
            result = false
          else
            result = primitive_comparison(:<, runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '<', one_or_more, primitive)
      end

      def create_gt(aRuntime)
        primitive = lambda do |runtime, first_operand, arglist|
          if arglist.empty?
            result = false
          else
            result = primitive_comparison(:>, runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '>', one_or_more, primitive)
      end

      def create_lte(aRuntime)
        primitive = lambda do |runtime, first_operand, arglist|
          if arglist.empty?
            result = true
          else
            result = primitive_comparison(:<=, runtime, first_operand, arglist)
          end
          boolean(result)
        end

        define_primitive_proc(aRuntime, '<=', one_or_more, primitive)
      end

      def create_gte(aRuntime)
        primitive = lambda do |runtime, first_operand, arglist|
          if arglist.empty?
            result = true
          else
            result = primitive_comparison(:>=, runtime, first_operand, arglist)
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
        primitive = lambda do |_runtime, first_operand, arglist|
          if arglist.empty?
            result = first_operand
          else
            arr = arglist.to_a
            arr.unshift(first_operand)
            result = arr.max do |a, b|
              a.value <=> b.value if a.real? && b.real?
            end
          end

          result
        end

        define_primitive_proc(aRuntime, 'max', one_or_more, primitive)
      end

      def create_min(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          if arglist.empty?
            result = first_operand
          else
            arr = arglist.to_a
            arr.unshift(first_operand)
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
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmNumber, 'number', 'number->string')
          string(arg_evaluated.value)
        end

        define_primitive_proc(aRuntime, 'number->string', unary, primitive)
      end

      def create_and(aRuntime)
        # arglist should be a Ruby Array
        # Arguments aren't evaluated yet!...
        primitive = lambda do |runtime, arglist|
          if arglist.empty?
            boolean(true) # in conformance with 4.2.1
          else
            raw_result = true
            last_result = nil
            # $stderr.puts arglist.inspect
            arglist.each do |raw_arg|
              argument = raw_arg.evaluate(runtime)
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
        primitive = lambda do |runtime, arglist|
          if arglist.empty?
            boolean(false) # in conformance with 4.2.1
          else
            raw_result = false
            last_result = nil
            arglist.each do |raw_arg|
              argument = raw_arg.evaluate(runtime)
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

      # Return true, if all arguments have the same values
      def all_same?(first_operand, arglist)
        if arglist.empty?
          boolean(true)
        else
          first_value = first_operand.value
          all_equal = arglist.all? { |elem| first_value == elem.value }
          boolean(all_equal)
        end
      end

      # Return true, if all arguments are monotonously increasing
      def compare_all(first_operand, arglist, operation)
        if arglist.empty?
          result = true
        else
          result = first_operand.value.send(operation, arglist[0].value)
          if result
            arglist.each_cons(2) do |(operand1, operand2)|
              value1 = operand1.value
              result &&= value1.send(operation, operand2.value)
            end
          end
        end
        boolean(result)
      end

      def create_boolean_equal(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          compare_all(first_operand, arglist, :==)
        end

        define_primitive_proc(aRuntime, 'boolean=?', one_or_more, primitive)
      end

      def create_char2int(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmChar, 'character', 'char->integer')
          integer(arg_evaluated.value.ord)
        end

        define_primitive_proc(aRuntime, 'char->integer', unary, primitive)
      end

      def create_int2char(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmInteger, 'integer', 'integer->char')
          char(arg_evaluated.value.ord)
        end

        define_primitive_proc(aRuntime, 'integer->char', unary, primitive)
      end

      def create_char_equal(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          compare_all(first_operand, arglist, :==)
        end

        define_primitive_proc(aRuntime, 'char=?', one_or_more, primitive)
      end

      def create_char_lt(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          compare_all(first_operand, arglist, :<)
        end

        define_primitive_proc(aRuntime, 'char<?', one_or_more, primitive)
      end

      def create_char_gt(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          compare_all(first_operand, arglist, :>)
        end

        define_primitive_proc(aRuntime, 'char>?', one_or_more, primitive)
      end

      def create_char_lte(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          compare_all(first_operand, arglist, :<=)
        end

        define_primitive_proc(aRuntime, 'char<=?', one_or_more, primitive)
      end

      def create_char_gte(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          compare_all(first_operand, arglist, :>=)
        end

        define_primitive_proc(aRuntime, 'char>=?', one_or_more, primitive)
      end

      def create_make_string(aRuntime)
        primitive = lambda do |_runtime, count_arg, arglist|
          count = count_arg
          check_argtype(count, SkmInteger, 'integer', 'make-string')
          if arglist.empty?
            filler = SkmChar.create(rand(0xff).chr)
          else
            filler = arglist.first
            check_argtype(filler, SkmChar, 'char', 'make-string')
          end
          string(filler.value.to_s * count.value)
        end

        define_primitive_proc(aRuntime, 'make-string', one_or_two, primitive)
      end

      def create_string_string(aRuntime)
        primitive = lambda do |_runtime, arglist|
          if arglist.empty?
            value = ''
          else
            value = arglist.reduce(+'') do |interim, some_char|
              check_argtype(some_char, SkmChar, 'character', 'string')
              interim << some_char.value
            end
          end

          string(value)
        end

        define_primitive_proc(aRuntime, 'string', zero_or_more, primitive)
      end

      def create_string_equal(aRuntime)
        primitive = lambda do |_runtime, first_operand, arglist|
          all_same?(first_operand, arglist)
        end

        define_primitive_proc(aRuntime, 'string=?', one_or_more, primitive)
      end

      def create_string_append(aRuntime)
        primitive = lambda do |_runtime, arglist|
          if arglist.empty?
            value = ''
          else
            value = arglist.reduce(+'') { |interim, substr| interim << substr.value }
          end

          string(value)
        end

        define_primitive_proc(aRuntime, 'string-append', zero_or_more, primitive)
      end

      def create_string_length(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmString, 'string', 'string-length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'string-length', unary, primitive)
      end

      def create_string2symbol(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmString, 'string', 'string->symbol')
          identifier(arg_evaluated)
        end

        define_primitive_proc(aRuntime, 'string->symbol', unary, primitive)
      end

      def create_symbol2string(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmIdentifier, 'symbol', 'symbol->string')
          string(arg_evaluated)
        end

        define_primitive_proc(aRuntime, 'symbol->string', unary, primitive)
      end

      def create_car(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmPair, 'pair', 'car')
          arg_evaluated.car
        end

        define_primitive_proc(aRuntime, 'car', unary, primitive)
      end

      def create_cdr(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmPair, 'pair', 'cdr')
          arg_evaluated.cdr
        end

        define_primitive_proc(aRuntime, 'cdr', unary, primitive)
      end

      def create_cons(aRuntime)
        primitive = lambda do |_runtime, obj1, obj2|
          SkmPair.new(obj1, obj2)
        end

        define_primitive_proc(aRuntime, 'cons', binary, primitive)
      end

      def create_make_list(aRuntime)
        primitive = lambda do |_runtime, count_arg, arglist|
          count = count_arg
          check_argtype(count, SkmInteger, 'integer', 'make-list')
          if arglist.empty?
            filler = SkmUndefined.instance
          else
            filler = arglist.first
          end
          arr = Array.new(count.value, filler)
          SkmPair.create_from_a(arr)
        end

        define_primitive_proc(aRuntime, 'make-list', one_or_two, primitive)
      end

      def create_length(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'length', unary, primitive)
      end

      def create_list2vector(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
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
          result = arglist.shift.klone # First list is taken
          arglist.each do |arg|
            case arg
              when SkmPair
                cloned = arg.klone
                if result.kind_of?(SkmEmptyList)
                  result = cloned
                else
                  result.append_list(cloned)
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
        primitive = lambda do |runtime, arglist|
          if arglist.size > 1
            arguments = evaluate_arguments(arglist, runtime)
          else
            arguments = arglist
          end

          append_core(arguments)
        end

        define_primitive_proc(aRuntime, 'append', zero_or_more, primitive)
      end

      def create_reverse(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'reverse')
          if arg_evaluated == SkmEmptyList.instance
            result = arg_evaluated
          else
            err_msg = 'reverse procedure requires a proper list as argument'
            raise StandardError, err_msg unless arg_evaluated.proper?

            elems_reversed = arg_evaluated.to_a.reverse
            result = SkmPair.create_from_a(elems_reversed)
          end
          result
        end

        define_primitive_proc(aRuntime, 'reverse', unary, primitive)
      end

      def create_setcar(aRuntime)
        # Arguments aren't evaluated yet!...
        primitive = lambda do |runtime, pair_arg, obj_arg|
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
        primitive = lambda do |runtime, pair_arg, obj_arg|
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
        primitive = lambda do |runtime, obj_arg, alist_arg|
          assoc_list = alist_arg.evaluate(runtime)
          check_assoc_list(assoc_list, 'assq')
          obj = obj_arg.evaluate(runtime)
          result = boolean(false)
          unless assoc_list.empty?
            pair = assoc_list
            loop do
              are_equal = core_eq?(pair.car.car, obj)
              if are_equal.value
                result = pair.car
                break
              end
              pair = pair.cdr
              break unless pair.kind_of?(SkmPair)
            end
          end

          result
        end
        define_primitive_proc(aRuntime, 'assq', binary, primitive)
      end

      def create_assv(aRuntime)
        primitive = lambda do |_runtime, obj, assoc_list|
          check_assoc_list(assoc_list, 'assq')
          result = boolean(false)
          unless assoc_list.empty?
            pair = assoc_list
            loop do
              are_equal = core_eqv?(pair.car.car, obj)
              if are_equal.value
                result = pair.car
                break
              end
              pair = pair.cdr
              break unless pair.kind_of?(SkmPair)
            end
          end

          result
        end
        define_primitive_proc(aRuntime, 'assv', binary, primitive)
      end

      def check_assoc_list(alist, proc_name)
        check_argtype(alist, [SkmPair, SkmEmptyList], 'association list', proc_name)

        unless alist.empty?
          cell = SkmPair.new(integer(1), alist)
          loop do
            cell = cell.cdr
            check_argtype(cell, SkmPair, 'association list', proc_name)
            break unless cell.cdr.kind_of?(SkmPair)
          end
        end
      end

      def create_list_copy(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, [SkmPair, SkmEmptyList], 'list', 'list-copy')
          arg_evaluated.klone # Previously: arg.klone
        end

        define_primitive_proc(aRuntime, 'list-copy', unary, primitive)
      end

      def create_vector(aRuntime)
        primitive = lambda do |_runtime, elements|
          vector(elements)
        end

        define_primitive_proc(aRuntime, 'vector', zero_or_more, primitive)
      end

      def create_vector_length(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmVector, 'vector', 'vector-length')
          integer(arg_evaluated.length)
        end

        define_primitive_proc(aRuntime, 'vector-length', unary, primitive)
      end

      def create_make_vector(aRuntime)
        primitive = lambda do |runtime, count_arg, arglist|
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
        primitive = lambda do |_runtime, vector, index|
          check_argtype(vector, SkmVector, 'vector', 'vector-ref')
          check_argtype(index, SkmInteger, 'integer', 'vector-ref')
          # TODO: index checking
          raw_result = vector.members[index.value]
          to_datum(raw_result) # What if non-datum result?
        end

        define_primitive_proc(aRuntime, 'vector-ref', binary, primitive)
      end

      def create_vector_set(aRuntime)
        # Arguments aren't evaluated yet!...
        primitive = lambda do |runtime, vector, k, object|
          index = k.evaluate(runtime)
          check_argtype(vector, SkmVector, 'vector', 'vector-set!')
          check_argtype(index, SkmInteger, 'integer', 'vector-set!')
          # TODO: index checking
          vector.members[index.value] = object
          vector
        end

        define_primitive_proc(aRuntime, 'vector-set!', ternary, primitive)
      end

      def create_vector2list(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          check_argtype(arg_evaluated, SkmVector, 'vector', 'vector->list')
          SkmPair.create_from_a(arg_evaluated.members)
        end

        define_primitive_proc(aRuntime, 'vector->list', unary, primitive)
      end

      def create_apply(aRuntime)
        primitive = lambda do |runtime, proc_arg, arglist|
          if arglist.empty?
            result = SkmEmptyList.instance
          else
            single_list = append_core(arglist)
            invoke = ProcedureCall.new(nil, proc_arg, single_list.to_a)
            result = invoke.evaluate(runtime)
          end
          result
        end

        define_primitive_proc(aRuntime, 'apply', one_or_more, primitive)
      end

      def create_map(aRuntime)
        primitive = lambda do |runtime, proc_arg, arglist|
          if arglist.empty?
            result = SkmEmptyList.instance
          else
            curr_cells = arglist
            # arity = curr_cells.size
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
              break if curr_cells.find { |cdr_entry| !cdr_entry.kind_of?(SkmPair) }
            end

            result = initial_result
          end

          result
        end

        define_primitive_proc(aRuntime, 'map', one_or_more, primitive)
      end

      def create_display(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          # @TODO: make output stream configurable
          print arg_evaluated.value.to_s
          SkmUndefined.instance
        end

        define_primitive_proc(aRuntime, 'display', unary, primitive)
      end

      def create_error(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          raise SkmError, arg_evaluated.value
        end

        define_primitive_proc(aRuntime, 'error', unary, primitive)
      end

      def create_test_assert(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          if arg_evaluated.boolean? && arg_evaluated.value == false
            assert_call = aRuntime.caller
            pos = assert_call.call_site
            # Error: assertion failed: (> 1 2)
            msg1 = "assertion failed on line #{pos.line}, column #{pos.column}"
            msg2 = ", with #{arg_evaluated.inspect}"
            raise StandardError, "Error: #{msg1}#{msg2}"
          else
            boolean(true)
          end
        end

        define_primitive_proc(aRuntime, 'test-assert', unary, primitive)
      end

      # DON'T USE IT
      # Non-standard procedure reserved for internal testing/debugging purposes.
      def create_debug(aRuntime)
        primitive = lambda do |_runtime|
          require 'debug'
        end

        define_primitive_proc(aRuntime, 'debug', nullary, primitive)
      end

      # DON'T USE IT
      # Non-standard procedure reserved for internal testing/debugging purposes.
      def create_inspect(aRuntime)
        primitive = lambda do |_runtime, arg_evaluated|
          $stderr.puts "INSPECT>#{arg_evaluated.inspect}"
          Skeem::SkmUndefined.instance
        end
        define_primitive_proc(aRuntime, '_inspect', unary, primitive)
      end

      def create_object_predicate(aRuntime, predicate_name, msg_name = nil)
        msg_name = predicate_name if msg_name.nil?
        primitive = lambda do |_runtime, arg_evaluated|
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
        raise StandardError, "#{msg1} #{msg2}"
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
