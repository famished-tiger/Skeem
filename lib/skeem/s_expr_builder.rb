require 'stringio'
require_relative 'skm_pair'
require_relative 'skm_binding'
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
      # $stderr.puts last_child.inspect
      result = if last_child.length == 1
                  last_child.car
                else
                  last_child
                end
    end

    # rule('cmd_or_def_plus' => 'cmd_or_def_plus cmd_or_def').as 'multiple_cmd_def'
    def reduce_multiple_cmd_def(_production, _range, _tokens, theChildren)
      theChildren[0].append(theChildren[1])
      theChildren[0]
    end

    # rule('cmd_or_def_plus' => 'cmd_or_def').as 'last_cmd_def'
    def reduce_last_cmd_def(_production, _range, _tokens, theChildren)
      SkmPair.create_from_a([theChildren.last])
    end

    # rule('definition' => 'LPAREN DEFINE IDENTIFIER expression RPAREN')
    #  .as 'definition'
    def reduce_definition(_production, _range, _tokens, theChildren)
      SkmBinding.new(theChildren[2], theChildren[3])
    end

    # rule('definition' => 'LPAREN DEFINE LPAREN IDENTIFIER def_formals RPAREN body RPAREN').as 'alt_definition'
    # Equivalent to: (define IDENTIFIER (lambda (formals) body))
    def reduce_alt_definition(_production, aRange, _tokens, theChildren)
      lmbd = SkmLambda.new(aRange, theChildren[4], theChildren[6])
      # $stderr.puts lmbd.inspect
      SkmBinding.new(theChildren[3], lmbd)
    end

    # rule('expression' =>  'IDENTIFIER').as 'variable_reference'
    def reduce_variable_reference(_production, aRange, _tokens, theChildren)
      SkmVariableReference.new(aRange, theChildren[0])
    end

    # rule('quotation' => 'APOSTROPHE datum').as 'quotation_short'
    def reduce_quotation_short(_production, _range, _tokens, theChildren)
      theChildren[1].quoted!
      if theChildren[1].verbatim?
        theChildren[1]
      else
        SkmQuotation.new(theChildren[1])
      end
    end

    # rule('quotation' => 'LPAREN QUOTE datum RPAREN').as 'quotation'
    def reduce_quotation(_production, _range, _tokens, theChildren)
      theChildren[2].quoted!
      if theChildren[2].verbatim?
        theChildren[2]
      else
        SkmQuotation.new(theChildren[2])
      end
    end

    # rule('list' => 'LPAREN datum_star RPAREN').as 'list'
    def reduce_list(_production, _range, _tokens, theChildren)
      unless theChildren[1].empty?
        first_elem = theChildren[1].first
        first_elem.is_var_name = true if first_elem.kind_of?(SkmIdentifier)
      end
      SkmPair.create_from_a(theChildren[1])
    end

    # rule('list' => 'LPAREN datum_plus PERIOD datum RPAREN').as 'dotted_list'
    def reduce_dotted_list(_production, _range, _tokens, theChildren)
      # if theChildren[1].kind_of?(Array)
        # if theChildren[1].size == 1
          # car_arg = theChildren[1].first
        # else
          # car_arg = SkmPair.create_from_a(theChildren[1])
        # end
      # else
        # car_arg = theChildren[1]
      # end

      SkmPair.new(theChildren[1], theChildren[3])
    end

    # rule('vector' => 'VECTOR_BEGIN datum_star RPAREN').as 'vector'
    def reduce_vector(_production, aRange, _tokens, theChildren)
      SkmVector.new(theChildren[1])
    end

    # rule('datum_star' => 'datum_star datum').as 'datum_star'
    def reduce_datum_star(_production, aRange, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('datum_star' => []).as 'no_datum_yet'
    def reduce_no_datum_yet(_production, aRange, _tokens, theChildren)
      []
    end

    # rule('procedure_call' => 'LPAREN operator RPAREN').as 'proc_call_nullary'
    def reduce_proc_call_nullary(_production, aRange, _tokens, theChildren)
      ProcedureCall.new(aRange, theChildren[1], [])
    end

    # rule('proc_call_args' => 'LPAREN operator operand_plus RPAREN')
    def reduce_proc_call_args(_production, aRange, _tokens, theChildren)
      pcall = ProcedureCall.new(aRange, theChildren[1], theChildren[2])
      if theChildren[1].kind_of?(SkmVariableReference)
          pcall.call_site = theChildren[1].child.token.position
      end

      pcall
    end

    # rule('operand_plus' => 'operand_plus operand').as 'multiple_operands'
    def reduce_multiple_operands(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('operand_plus' => 'operand').as 'last_operand'
    def reduce_last_operand(_production, _range, _tokens, theChildren)
      [theChildren.last]
    end

    # rule('operand_plus' => 'operand').as 'last_operand'
    def reduce_last_operand(_production, _range, _tokens, theChildren)
      [theChildren.last]
    end

    # rule('def_formals' => 'identifier_star').as 'def_formals'
    def reduce_def_formals(_production, _range, _tokens, theChildren)
      SkmFormals.new(theChildren[0], :fixed)
    end

    # rule('def_formals' => 'identifier_star PERIOD identifier').as 'pair_formals'
    def reduce_pair_formals(_production, _range, _tokens, theChildren)
      formals = theChildren[0] << theChildren[2]
      SkmFormals.new(formals, :variadic)
    end

    # rule('lambda_expression' => 'LPAREN LAMBDA formals body RPAREN').as 'lambda_expression'
    def reduce_lambda_expression(_production, aRange, _tokens, theChildren)
      lmbd = SkmLambda.new(aRange, theChildren[2], theChildren[3])
      # $stderr.puts lmbd.inspect
      lmbd
    end

    # rule('formals' => 'LPAREN identifier_star RPAREN').as 'fixed_arity_formals'
    def reduce_fixed_arity_formals(_production, _range, _tokens, theChildren)
      SkmFormals.new(theChildren[1], :fixed)
    end

    # rule('formals' => 'IDENTIFIER').as 'variadic_formals'
    def reduce_variadic_formals(_production, _range, _tokens, theChildren)
      SkmFormals.new([theChildren[0]], :variadic)
    end

    # rule('formals' => 'LPAREN identifier_plus PERIOD IDENTIFIER RPAREN').as 'dotted_formals'
    def reduce_dotted_formals(_production, _range, _tokens, theChildren)
      formals = theChildren[1] << theChildren[3]
      SkmFormals.new(formals, :variadic)
    end

    # rule('identifier_star' => 'identifier_star IDENTIFIER').as 'identifier_star'
    def reduce_identifier_star(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('identifier_star' => []).as 'no_identifier_yet'
    def reduce_no_identifier_yet(_production, _range, _tokens, theChildren)
      []
    end

    # rule('identifier_plus' => 'identifier_plus IDENTIFIER').as 'multiple_identifiers'
    def reduce_multiple_identifiers(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('identifier_plus' => 'IDENTIFIER').as 'last_identifier'
    def reduce_last_identifier(_production, _range, _tokens, theChildren)
      [theChildren[0]]
    end

    # rule('body' => 'definition_star sequence').as 'body'
    def reduce_body(_production, _range, _tokens, theChildren)
      definitions = theChildren[0].nil? ? [] : theChildren[0]
      { defs: definitions, sequence: theChildren[1] }
    end

    # rule('sequence' => 'command_star expression').as 'sequence'
    def reduce_sequence(_production, _range, _tokens, theChildren)
      SkmPair.create_from_a(theChildren[0] << theChildren[1])
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

    # rule('assignment' => 'LPAREN SET! IDENTIFIER expression RPAREN').as 'assignment'
    def reduce_assignment(_production, _range, _tokens, theChildren)
      SkmUpdateBinding.new(theChildren[2], theChildren[3])
    end

    # rule('derived_expression' => 'LPAREN LET LPAREN binding_spec_star RPAREN body RPAREN').as 'short_let_form'
    def reduce_short_let_form(_production, aRange, _tokens, theChildren)
      SkmBindingBlock.new(:let, theChildren[3], theChildren[5])
    end
    
    # rule('derived_expression' => 'LPAREN LET* LPAREN binding_spec_star RPAREN body RPAREN').as 'let_star_form'
    def reduce_let_star_form(_production, aRange, _tokens, theChildren)
      SkmBindingBlock.new(:let_star, theChildren[3], theChildren[5])
    end    

    # rule('quasiquotation' => 'LPAREN QUASIQUOTE qq_template RPAREN').as 'quasiquotation'
    def reduce_quasiquotation(_production, aRange, _tokens, theChildren)
      SkmQuasiquotation.new(theChildren[2])
    end

    # rule('quasiquotation' => 'GRAVE_ACCENT qq_template').as 'quasiquotation_short'
    def reduce_quasiquotation_short(_production, aRange, _tokens, theChildren)
      SkmQuasiquotation.new(theChildren[1])
    end

    # rule('binding_spec_star' => 'binding_spec_star binding_spec').as 'multiple_binding_specs'
    def reduce_multiple_binding_specs(_production, aRange, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('binding_spec_star' => []).as 'no_binding_spec_yet'
    def reduce_no_binding_spec_yet(_production, aRange, _tokens, _children)
      []
    end

    # rule('binding_spec' => 'LPAREN IDENTIFIER expression RPAREN').as 'binding_spec'
    def reduce_binding_spec(production, _range, _tokens, theChildren)
      SkmBinding.new(theChildren[1], theChildren[2])
    end

    # rule('list_qq_template' => 'LPAREN qq_template_or_splice_star RPAREN').as 'list_qq'
    def reduce_list_qq(_production, _range, _tokens, theChildren)
      SkmPair.create_from_a(theChildren[1])
    end

    # rule('vector_qq_template' => 'VECTOR_BEGIN qq_template_or_splice_star RPAREN').as 'vector_qq'
    def reduce_vector_qq(_production, _range, _tokens, theChildren)
      SkmVector.new(theChildren[1])
    end

    # rule('unquotation' => 'COMMA qq_template').as 'unquotation_short'
    def reduce_unquotation_short(_production, aRange, _tokens, theChildren)
      SkmUnquotation.new(theChildren[1])
    end

    # rule('qq_template_or_splice_star' => 'qq_template_or_splice_star qq_template_or_splice').as 'multiple_template_splice'
    def reduce_multiple_template_splice(_production, _range, _tokens, theChildren)
      theChildren[0] << theChildren[1]
    end

    # rule('qq_template_or_splice_star' => []).as 'no_template_splice_yet'
    def reduce_no_template_splice_yet(_production, _range, _tokens, theChildren)
      []
    end


  end # class
end # module
# End of file