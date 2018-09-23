# Grammar for Skeem (a subset of Scheme language)
require 'rley' # Load the gem

module Skeem
  ########################################
  # Define a grammar for Skeem
  # Official Small Scheme grammar is available at:
  # https://bitbucket.org/cowan/r7rs/src/draft-10/rnrs/r7rs.pdf
  # Names of grammar elements are based on the R7RS documentation
  builder = Rley::Syntax::GrammarBuilder.new do
    # Delimiters, separators...
    # add_terminals('APOSTROPHE', 'BACKQUOTE')
    add_terminals('LPAREN', 'RPAREN')
    add_terminals('PERIOD')

    # Literal values...
    add_terminals('BOOLEAN', 'INTEGER', 'REAL')
    add_terminals('STRING_LIT', 'IDENTIFIER')

    # Keywords...
    add_terminals('DEFINE', 'IF', 'LAMBDA')

    rule('program' => 'cmd_or_def_plus').as 'main'
    rule('cmd_or_def_plus' => 'cmd_or_def_plus cmd_or_def').as 'multiple_cmd_def'
    rule('cmd_or_def_plus' => 'cmd_or_def').as 'last_cmd_def'
    rule 'cmd_or_def' => 'command'
    rule 'cmd_or_def' => 'definition'
    rule 'command' => 'expression'
    rule('definition' => 'LPAREN DEFINE IDENTIFIER expression RPAREN').as 'definition'
    rule('expression' =>  'IDENTIFIER').as 'variable_reference'
    rule 'expression' =>  'literal'
    rule 'expression' =>  'procedure_call'
    rule 'expression' =>  'lambda_expression'
    rule 'expression' =>  'conditional'
    rule 'literal' => 'self-evaluating'
    rule 'self-evaluating' => 'BOOLEAN'
    rule 'self-evaluating' => 'number'
    rule 'self-evaluating' => 'STRING_LIT'
    rule 'procedure_call' => 'LPAREN operator RPAREN'
    rule('procedure_call' => 'LPAREN operator operand_plus RPAREN').as 'proc_call_args'
    rule('operand_plus' => 'operand_plus operand').as 'multiple_operands'
    rule('operand_plus' => 'operand').as 'last_operand'
    rule 'operator' => 'expression'
    rule 'operand' => 'expression'
    rule('lambda_expression' => 'LPAREN LAMBDA formals body RPAREN').as 'lambda_expression'
    rule('formals' => 'LPAREN identifier_star RPAREN').as 'identifiers_as_formals'
    rule 'formals' => 'IDENTIFIER'
    rule 'formals' => 'LPAREN identifier_plus PERIOD IDENTIFIER RPAREN'
    rule('identifier_star' => 'identifier_star IDENTIFIER').as 'identifier_star'
    rule('identifier_star' => []).as 'no_identifier_yet'
    rule 'identifier_plus' => 'identifier_plus IDENTIFIER'
    rule 'identifier_plus' => 'IDENTIFIER'
    rule('body' => 'definition_star sequence').as 'body'
    rule 'definition_star' => 'definition_star definition'
    rule 'definition_star' => []
    rule('sequence' => 'command_star expression').as 'sequence'
    rule('command_star' => 'command_star command').as 'multiple_commands'
    rule('command_star' => []).as 'no_command_yet'
    rule('conditional' => 'LPAREN IF test consequent alternate RPAREN').as 'conditional'
    rule 'test' => 'expression'
    rule 'consequent' => 'expression'
    rule 'alternate' => 'expression'
    rule 'alternate' => []
    rule 'number' => 'INTEGER'
    rule 'number' => 'REAL'
  end

  # And now build the grammar and make it accessible via a global constant
  # [Rley::Syntax::Grammar]
  Grammar = builder.grammar
end # module
