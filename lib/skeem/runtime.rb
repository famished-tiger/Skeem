# frozen_string_literal: true

require_relative 's_expr_nodes'

module Skeem
  class Runtime
    # @return [Array<SkmFrame>] The current active frame
    attr_reader(:env_stack)

    # @return [Array<ProcedureCall>] The call stack
    attr_reader(:call_stack)

    def initialize(anEnvironment, parent = nil)
      @env_stack = []
      push(anEnvironment)
      @call_stack = parent.nil? ? [] : parent.call_stack
    end

    def environment
      env_stack.last
    end

    def include?(anIdentifier)
      environment.include?(anIdentifier)
    end

    def fetch(aKey)
      include?(aKey) ? environment.fetch(aKey) : nil
    end

    def add_binding(aKey, anEntry)
      environment.add_binding(aKey, anEntry)
    end

    def update_binding(aKey, anEntry)
      environment.update_binding(aKey, anEntry)
    end

    def evaluate(aKey)
      key_value = normalize_key(aKey)
      if include?(key_value)
        entry = environment.fetch(key_value)
        result = nil
        begin
          result = entry.evaluate(self)

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
      nested = SkmFrame.new(environment)
      push(nested)
    end

    def unnest
      raise StandardError, 'Cannot unnest environment' unless environment.parent
      environment.bindings.clear
      pop
    end

    def depth
      return env_stack.size
    end

    def push(anEnvironment)
      env_stack.push(anEnvironment)
    end

    # Make the parent frame the current one inside the provided block
    def pop
      if env_stack.empty?
        raise StandardError, 'Skeem environment stack empty!'
      end
      env_stack.pop
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

    def pop_call
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
                 when SkmVariableReference
                    aKey.child.value
                 else
                   aKey.evaluate(self).value
               end

      result
    end
  end # class
end # module