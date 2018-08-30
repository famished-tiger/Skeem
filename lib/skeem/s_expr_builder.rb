require 'stringio'
require_relative 's_expr_nodes'

module Skeem
  # The purpose of a ASTBuilder is to build piece by piece an AST
  # (Abstract Syntax Tree) from a sequence of input tokens and
  # visit events produced by walking over a GFGParsing object.
  # Uses the Builder GoF pattern.
  # The Builder pattern creates a complex object
  # (say, a parse tree) from simpler objects (terminal and non-terminal
  # nodes) and using a step by step approach.
  class SExprBuilder < Rley::ParseRep::ASTBaseBuilder
    Terminal2NodeClass = {
      'BOOLEAN' => SExprBooleanNode,
      'IDENTIFIER' => SExprIdentifierNode,
      'INTEGER' => SExprIntegerNode,
      'REAL' => SExprRealNode,
      'STRING_LIT' => SExprStringNode
    }.freeze

    # Create a new AST builder instance.
    # @param theTokens [Array<Token>] The sequence of input tokens.
    def initialize(theTokens)
      super(theTokens)
    end

    # Notification that the parse tree construction is complete.
    def done!
      super
    end

    protected

    def terminal2node
      Terminal2NodeClass
    end
  end # class
end # module
# End of file