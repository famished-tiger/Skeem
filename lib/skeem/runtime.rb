require_relative 's_expr_nodes'
require_relative 'environment'

module Skeem
  class Runtime
    # @return [Environment]
    attr_reader(:environment)

    # @return [Array<ProcedureCall>] The call stack
    attr_reader(:call_stack)

    def initialize(anEnvironment)
      @environment = anEnvironment
      @call_stack = []
    end

    def include?(anIdentifier)
      environment.include?(normalize_key(anIdentifier))
    end

    def fetch(aKey)
      key_value = normalize_key(aKey)
      include?(key_value) ? environment.fetch(key_value) : nil
    end

    def define(aKey, anEntry)
      environment.define(normalize_key(aKey), anEntry)
    end

    def evaluate(aKey)
      key_value = normalize_key(aKey)
      if include?(key_value)
        entry = environment.fetch(key_value)
        result = nil
        begin
          case entry
            when Primitive::PrimitiveProcedure
              result = entry
            when SkmDefinition
              result = entry.expression.evaluate(self)
            else
              raise StandardError, entry.inspect
          end
        rescue NoMethodError => exc
          # $stderr.puts 'In rescue block'
          # $stderr.puts key_value.inspect
          # $stderr.puts entry.inspect
          # $stderr.puts entry.expression.inspect
          raise exc
        end
        result
      else
        err = StandardError
        key = aKey.kind_of?(SkmIdentifier) ? aKey.value : key_value
        err_msg = "Unbound variable: '#{key}'"
        raise err, err_msg
      end
    end

    # @param aList[SkmPair] first member is an identifier.
    def evaluate_form(aList)
      # TODO: manage the cases where first_member is a keyword
      first_member = aList.car
      invokation = ProcedureCall.new(nil, first_member, aList.cdr.to_a)
      invokation.evaluate(self)
    end

    def nest()
      nested = Environment.new(environment)
      @environment = nested
    end

    def unnest()
      raise StandardError, 'Cannot unnest environment' unless environment.outer
      environment.bindings.clear
      @environment = environment.outer
    end

    def depth()
      return environment.depth
    end

    def push(anEnvironment)
      @environment = anEnvironment
    end

    # Make the outer enviromnent thecurrent one inside the provided block
    def pop
      env = environment
      @environment = environment.outer
      env
    end

    def push_call(aProcCall)
      if aProcCall.kind_of?(ProcedureCall)
        call_stack.push(aProcCall)
      else
        raise StandardError, "Invalid call object #{aProcCall.inspect}"
      end
      # $stderr.puts 'CALL STACK vvvv'
      # call_stack.each do |proc_call|
      # $stderr.puts proc_call.inspect
      # end
      # $stderr.puts 'CALL STACK ^^^^'
    end

    def pop_call()
      if call_stack.empty?
        raise StandardError, 'Skeem call stack empty!'
      end
      call_stack.pop
    end

    def caller(index = -1)
      call_stack[index]
    end

    private

    def normalize_key(aKey)
      result = case aKey
                 when String
                   aKey
                 else
                   aKey.evaluate(self).value
               end

      result
    end
  end # class
end # module