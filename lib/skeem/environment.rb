require 'forwardable'

module Skeem
  class Environment
    extend Forwardable
    def_delegator :@bindings, :empty?
    
    attr_reader(:bindings)

    def initialize()
      @bindings = {}
    end

    def define(anIdentifier, anExpression)
      raise StandardError, anIdentifier unless anIdentifier.kind_of?(String)
      @bindings[anIdentifier] = anExpression
    end
  end # class
end # module