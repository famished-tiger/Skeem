require_relative '../s_expr_nodes'

module Skeem
  module Primitive
    class PrimitiveProcedure
      attr_reader(:identifier)
      attr_reader(:arity)
      attr_reader(:code)

      # param [anArity] Arity of the lambda code (ignoring the runtime object)
      def initialize(anId, anArity, aRubyLambda)
        @identifier = anId.kind_of?(String) ? SkmIdentifier.create(anId) : anId
        @code = code_validated(aRubyLambda)
        @arity = arity_validated(anArity)
      end

      def callable?
        true
      end

      # This method should be invoked when the procedure isn't
      # explicitly called (with arguments). In this case, the name
      # of procedure just returns the procedure object itself.
      # @param _runtime [Runtime]
      # @return [PrimitiveProcedure]
      def evaluate(_runtime)
        self
      end

      # Arguments are positional in a primitive procedure.
      # @param theActuals [Array<SkmElement>]
      def call(aRuntime, theActuals)
        actuals = theActuals
        # $stderr.puts "--- Start of procedure #{identifier}"
        # actuals.each { |actual| $stderr.puts '  Actual: ' + actual.inspect }
        check_actual_count(actuals)
        # TODO: check that next line became useless
        # aProcedureCall.operands_consumed = true
        result = do_call(aRuntime, actuals)
        # $stderr.puts "  Result: #{result.inspect}"
        # $stderr.puts "--- End of procedure #{identifier}"
        result
      end

      def skm_equal?(other)
        equal?(other)
      end

      # Notification that this procedure is bound to a variable
      # @param [Skemm::SkmFrame]
      def bound!(_frame)
        # Do nothing
      end

      private

      def code_validated(aRubyLambda)
        unless aRubyLambda.lambda?
          error_lambda('must be implemented with a Ruby lambda.')
        end
        if aRubyLambda.parameters.size.zero?
          error_lambda('lambda takes no parameter.')
        end

        aRubyLambda
      end

      def arity_validated(anArity)
        count_param = code.parameters.size

        if anArity.variadic?
          if (anArity.low + 2) != count_param
            discrepancy_arity_argument_count(anArity.low, count_param, 2)
          end
        else # fixed arity...
          if (anArity.high + 1) != count_param
            discrepancy_arity_argument_count(anArity.high, count_param, 1)
          end
        end

        anArity
      end

      def check_actual_count(actuals)
        count_actuals = actuals.size
        if arity.nullary?
          unless count_actuals.zero?
            wrong_number_arguments(arity.high, count_actuals)
          end
        elsif arity.variadic?
          if count_actuals < arity.low
            wrong_number_arguments(arity.low, count_actuals)
          end
        elsif arity.low < arity.high # Arity range
          if count_actuals < arity.low
            wrong_number_arguments(arity.low, count_actuals)
          end
          if count_actuals > arity.high
            wrong_number_arguments(arity.high, count_actuals)
          end
        else # fixed non-zero arity...
          if count_actuals != arity.high
            wrong_number_arguments(arity.high, count_actuals)
          end
        end
      end

      def do_call(aRuntime, operands)
        if arity.nullary?
          result = code.call(aRuntime)
        elsif arity.variadic? || (arity.low < arity.high)
          if arity.low.zero?
            result = code.call(aRuntime, operands)
          else
            arguments = []
            arguments << operands.take(arity.low).flatten
            count_delta = operands.size - arity.low
            arguments << SkmPair.create_from_a(operands.slice(-count_delta, count_delta))
            # p operands.size
            # p count_delta
            # p arguments.inspect
            result = code.send(:call, aRuntime, *arguments.flatten)
          end
        else # Fixed arity...
          result = code.send(:call, aRuntime, *operands)
        end

        result
      end

      def error_lambda(message_suffix)
        msg1 = "Primitive procedure '#{identifier.value}'"
        raise StandardError, msg1 + ' ' + message_suffix
      end

      def discrepancy_arity_argument_count(arity_required, count_param, delta)
        msg1 = "Discrepancy in primitive procedure '#{identifier.value}'"
        msg2 = "between arity (#{arity_required}) + #{delta}"
        msg3 = "and parameter count of lambda #{count_param}."
        raise StandardError, msg1 + ' ' + msg2 + ' ' + msg3
      end

      def wrong_number_arguments(required, actual)
        msg1 = "Wrong number of arguments for #<Procedure #{identifier.value}>"
        msg2 = "(required at least #{required}, got #{actual})"
        raise StandardError, msg1 + ' ' + msg2
      end
    end # class
  end # module
end # module