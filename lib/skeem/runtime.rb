require_relative 's_expr_nodes'
require_relative 'environment'

module Skeem
  class Runtime
    attr_reader(:environment)

    def initialize(anEnvironment)
      @environment = anEnvironment
    end

    def include?(anIdentifier)
      environment.include?(normalize_key(anIdentifier))
    end

    def define(aKey, anEntry)
      environment.define(normalize_key(aKey), anEntry)
    end

    def evaluate(aKey)
      key_value = normalize_key(aKey)
      if include?(key_value)
        definition = environment.fetch(key_value)
        definition.expression.evaluate(self)
      else
        err = StandardError
        key = aKey.kind_of?(SkmIdentifier) ? aKey.value : key_value
        err_msg = "Unbound variable: '#{key}'"
        raise err, err_msg
      end
    end
    
    # @param aList[SkmList] first member is an identifier.
    def evaluate_form(aList)
      # TODO: manage the cases where first_member is a keyword
      first_member = aList.first
      invokation = ProcedureCall.new(nil, first_member, aList.tail.members)
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

    # Make the outer enviromnent thecurrent one inside the provided block
    def pop
      env = environment
      @environment = environment.outer
      env
    end

    def push(anEnvironment)
      @environment = anEnvironment
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