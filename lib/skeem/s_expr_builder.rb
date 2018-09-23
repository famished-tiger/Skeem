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
  class SkmBuilder < Rley::ParseRep::ASTBaseBuilder
    Terminal2NodeClass = {
      'BOOLEAN' => SkmBoolean,
      'IDENTIFIER' => SkmIdentifier,
      'INTEGER' => SkmInteger,
      'REAL' => SkmReal,
      'STRING_LIT' => SkmString
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

    # rule('program' => 'cmd_or_def_plus').as 'main'
    def reduce_main(_production, _range, _tokens, theChildren)
      last_child = theChildren.last
      result = if last_child.members.size == 1
                  last_child.members[0]
                else
                  last_child
                end
    end

    # rule('cmd_or_def_plus' => 'cmd_or_def_plus cmd_or_def').as 'multiple_cmd_def'
    def reduce_multiple_cmd_def(_production, _range, _tokens, theChildren)
      theChildren[0].members << theChildren[1]
      theChildren[0]
    end

    # rule('cmd_or_def_plus' => 'cmd_or_def').as 'last_cmd_def'
    def reduce_last_cmd_def(_production, _range, _tokens, theChildren)
      SkmList.new([theChildren.last])
    end

    # rule('definition' => 'LPAREN DEFINE IDENTIFIER expression RPAREN')
    #  .as 'definition'
    def reduce_definition(_production, aRange, _tokens, theChildren)
      SkmDefinition.new(aRange, theChildren[2], theChildren[3])
    end

    # rule('expression' =>  'IDENTIFIER').as 'variable_reference'
    def reduce_variable_reference(_production, aRange, _tokens, theChildren)
      SkmVariableReference.new(aRange, theChildren[0])
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
    
    # rule('lambda_expression' => 'LPAREN LAMBDA formals body RPAREN').as 'lambda_expression'
    def reduce_lambda_expression(_production, _range, _tokens, theChildren)
      lmbd = SkmLambda.new(_range, theChildren[2], theChildren[3])
      # puts lmbd.inspect
      lmbd
    end
    
    # rule('formals' => 'LPAREN identifier_star RPAREN').as 'identifiers_as_formals'
    def reduce_identifiers_as_formals(_production, _range, _tokens, theChildren)
      theChildren[1]
    end

    # rule('identifier_star' => 'identifier_star IDENTIFIER').as 'identifier_star'
    def reduce_identifier_star(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('identifier_star' => []).as 'no_identifier_yet'
    def reduce_no_identifier_yet(_production, _range, _tokens, theChildren)
      []
    end

    # rule('body' => 'definition_star sequence').as 'body'
    def reduce_body(_production, _range, _tokens, theChildren)
      definitions = theChildren[0].nil? ? [] : theChildren[0]
      { defs: definitions, sequence: theChildren[1] }
    end

    # rule('sequence' => 'command_star expression').as 'sequence'
    def reduce_sequence(_production, _range, _tokens, theChildren)
      SkmList.new(theChildren[0] << theChildren[1])
    end

    # rule('command_star' => 'command_star command').as 'multiple_commands'
    def reduce_multiple_commands(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('command_star' => []).as 'no_command_yet'
    def reduce_no_command_yet(_production, _range, _tokens, theChildren)
      []
    end

    # rule('conditional' => 'LPAREN IF test consequent alternate RPAREN').as 'conditional'
    def reduce_conditional(_production, aRange, _tokens, theChildren)
      SkmCondition.new(aRange, theChildren[2], theChildren[3], theChildren[4])
    end
  end # class
end # module
# End of file