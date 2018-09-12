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
      'BOOLEAN' => SExprBoolean,
      'IDENTIFIER' => SExprIdentifier,
      'INTEGER' => SExprInteger,
      'REAL' => SExprReal,
      'STRING_LIT' => SExprString
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

    # rule('proc_call_args' => 'LPAREN operator operand_plus RPAREN')
    def reduce_proc_call_args(_production, aRange, _tokens, theChildren)
      ProcedureCall.new(aRange, theChildren[1], theChildren[2])
    end

    # rule('operand_plus' => 'operand_plus operand').as 'multiple_operands'
    def reduce_multiple_operands(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('operand_plus' => 'operand').as 'last_operand'
    def reduce_last_operand(_production, _range, _tokens, theChildren)
      [theChildren.last]
    end
  end # class
end # module
# End of file