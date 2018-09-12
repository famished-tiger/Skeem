module Skeem
  class Runtime
    attr_reader(:environment)

    def initialize(anEnvironment)
      @environment = anEnvironment
    end

    def include?(anIdentifier)
      environment.bindings.include?(normalize_key(anIdentifier))
    end

    def define(aKey, anEntry)
      environment.define(normalize_key(aKey), anEntry)
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