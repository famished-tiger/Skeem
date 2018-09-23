require_relative 's_expr_nodes'

module Skeem
  class PrimitiveProcedure
    attr_reader(:identifier)
    attr_reader(:code)

    def initialize(anId, aRubyLambda)
      @identifier = anId.kind_of?(String) ? SkmIdentifier.create(anId) : anId
      @code = aRubyLambda
    end

    # Arguments are positional in a primitive procedure.
    def call(aRuntime, aProcedureCall)
      args = aProcedureCall.operands
      return @code.call(aRuntime, args)
    end
  end # class
end # module