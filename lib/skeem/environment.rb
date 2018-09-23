module Skeem
  class Environment
    attr_reader :outer

    attr_reader(:bindings)

    def initialize(outerEnv = nil)
      @bindings = {}
      @outer = outerEnv
    end

    def define(anIdentifier, anExpression)
      raise StandardError, anIdentifier unless anIdentifier.kind_of?(String)
      @bindings[anIdentifier] = anExpression
    end

    def fetch(anIdentifier)
      found = bindings[anIdentifier]
      if found.nil? && outer
        found = outer.fetch(anIdentifier)
      end

      found
    end

    def empty?
      my_result = bindings.empty?
      if my_result && outer
        my_result = outer.empty?
      end

      my_result
    end

    def size
      my_result = bindings.size
      my_result += outer.size if outer

      my_result
    end

    def include?(anIdentifier)
      my_result = bindings.include?(anIdentifier)
      if my_result == false  && outer
        my_result = outer.include?(anIdentifier)
      end

      my_result
    end
  end # class
end # module