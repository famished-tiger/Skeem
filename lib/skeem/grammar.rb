# Grammar for Skeem (a subset of Scheme language)
require 'rley' # Load the gem

module Skeem
  ########################################
  # Define a grammar for Skeem
  # Official Small Scheme grammar is available at:
  # https://bitbucket.org/cowan/r7rs/src/draft-10/rnrs/r7rs.pdf
  # Names of grammar elements are based on the R7RS documentation
  builder = Rley::Syntax::GrammarBuilder.new do
    # Delimitersn, separators...
    # add_terminals('APOSTROPHE', 'BACKQUOTE')    
    add_terminals('LPAREN', 'RPAREN')
    # add_terminals('PERIOD')

    # Literal values...
    add_terminals('BOOLEAN', 'INTEGER', 'REAL')
    add_terminals('STRING_LIT', 'IDENTIFIER')

    # Keywords...
    # add_terminals('BEGIN', 'DEFINE')
    add_terminals('DEFINE')
    
    rule 'program' => 'cmd_or_def_plus'
    rule 'cmd_or_def_plus' => 'cmd_or_def_plus cmd_or_def'
    rule 'cmd_or_def_plus' => 'cmd_or_def'
    rule 'cmd_or_def' => 'command'
    rule 'cmd_or_def' => 'definition'
    rule 'command' => 'expression'
    rule 'definition' => 'LPAREN DEFINE IDENTIFIER expression RPAREN'
    rule 'expression' =>  'IDENTIFIER'
    rule 'expression' =>  'literal'
    rule 'expression' =>  'procedure_call'
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
    rule 'number' => 'INTEGER'
    rule 'number' => 'REAL'
  end

  # And now build the grammar and make it accessible via a global constant
  # [Rley::Syntax::Grammar]
  Grammar = builder.grammar
end # module
