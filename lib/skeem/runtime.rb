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