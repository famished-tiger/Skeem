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

    # The number of outer parents the current environment has.
    # @return [Integer] The nesting levels
    def depth
      count = 0

      curr_env = self
      while curr_env.outer
        count += 1
        curr_env = curr_env.outer
      end

      count
    end

    def inspect
      result = ''
      if outer
        result << outer.inspect
      else
        return "\n"
      end
      result << "\n----\n"
      bindings.each_pair do |key, expr|
        result << "#{key.inspect} => #{expr.inspect}\n"
      end

      result
    end
  end # class
end # module