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
    add_terminals('APOSTROPHE', 'COMMA', 'COMMA_AT_SIGN')
    add_terminals('GRAVE_ACCENT', 'LPAREN', 'RPAREN')
    add_terminals('PERIOD', 'ARROW')
    add_terminals('VECTOR_BEGIN')

    # Literal values...
    add_terminals('BOOLEAN', 'INTEGER', 'REAL')
    add_terminals('STRING_LIT', 'IDENTIFIER')

    # Keywords...
    add_terminals('BEGIN', 'COND', 'DEFINE', 'ELSE')
    add_terminals('IF', 'LAMBDA', 'LET', 'LET*')
    add_terminals('QUOTE', 'QUASIQUOTE', 'SET!')
    add_terminals('UNQUOTE', 'UNQUOTE-SPLICING')

    rule('program' => 'cmd_or_def_plus').as 'main'
    rule('cmd_or_def_plus' => 'cmd_or_def_plus cmd_or_def').as 'multiple_cmd_def'
    rule('cmd_or_def_plus' => 'cmd_or_def').as 'last_cmd_def'
    rule 'cmd_or_def' => 'command'
    rule 'cmd_or_def' => 'definition'
    rule('cmd_or_def' => 'LPAREN BEGIN cmd_or_def_plus RPAREN').as 'begin_cmd'
    rule 'command' => 'expression'
    rule('definition' => 'LPAREN DEFINE IDENTIFIER expression RPAREN').as 'definition'
    rule('definition' => 'LPAREN DEFINE LPAREN IDENTIFIER def_formals RPAREN body RPAREN').as 'alt_definition'
    rule('definition' => 'LPAREN BEGIN definition_star RPAREN').as 'definitions_within_begin'
    rule('expression' => 'IDENTIFIER').as 'variable_reference'
    rule 'expression' => 'literal'
    rule 'expression' => 'procedure_call'
    rule 'expression' => 'lambda_expression'
    rule 'expression' => 'conditional'
    rule 'expression' => 'assignment'
    rule 'expression' => 'derived_expression'
    rule 'literal' => 'quotation'
    rule 'literal' => 'self-evaluating'   
    rule('quotation' => 'APOSTROPHE datum').as 'quotation_short'
    rule('quotation' => 'LPAREN QUOTE datum RPAREN').as 'quotation'
    rule 'self-evaluating' => 'BOOLEAN'
    rule 'self-evaluating' => 'number'
    rule 'self-evaluating' => 'STRING_LIT'
    rule 'self-evaluating' => 'vector'
    rule 'datum' => 'simple_datum'
    rule 'datum' => 'compound_datum'
    rule 'simple_datum' => 'BOOLEAN'
    rule 'simple_datum' => 'number'
    rule 'simple_datum' => 'STRING_LIT'
    rule 'simple_datum' => 'symbol'
    rule 'compound_datum' => 'list'
    rule 'compound_datum' => 'vector'
    rule('list' => 'LPAREN datum_star RPAREN').as 'list'
    rule('list' => 'LPAREN datum_plus PERIOD datum RPAREN').as 'dotted_list'
    rule('vector' => 'VECTOR_BEGIN datum_star RPAREN').as 'vector'
    rule('datum_plus' => 'datum_plus datum').as 'multiple_datums'
    rule('datum_plus' => 'datum').as 'last_datum'
    rule('datum_star' => 'datum_star datum').as 'datum_star'
    rule('datum_star' => []).as 'no_datum_yet'
    rule 'symbol' => 'IDENTIFIER'
    rule('procedure_call' => 'LPAREN operator RPAREN').as 'proc_call_nullary'
    rule('procedure_call' => 'LPAREN operator operand_plus RPAREN').as 'proc_call_args'
    rule('operand_plus' => 'operand_plus operand').as 'multiple_operands'
    rule('operand_plus' => 'operand').as 'last_operand'
    rule 'operator' => 'expression'
    rule 'operand' => 'expression'
    rule('def_formals' => 'identifier_star').as 'def_formals'
    rule('def_formals' => 'identifier_star PERIOD IDENTIFIER').as 'pair_formals'
    rule('lambda_expression' => 'LPAREN LAMBDA formals body RPAREN').as 'lambda_expression'
    rule('formals' => 'LPAREN identifier_star RPAREN').as 'fixed_arity_formals'
    rule('formals' => 'IDENTIFIER').as 'variadic_formals'
    rule('formals' => 'LPAREN identifier_plus PERIOD IDENTIFIER RPAREN').as 'dotted_formals'
    rule('identifier_star' => 'identifier_star IDENTIFIER').as 'identifier_star'
    rule('identifier_star' => []).as 'no_identifier_yet'
    rule('identifier_plus' => 'identifier_plus IDENTIFIER').as 'multiple_identifiers'
    rule('identifier_plus' => 'IDENTIFIER').as 'last_identifier'
    rule('body' => 'definition_star sequence').as 'body'
    rule('definition_star' => 'definition_star definition').as 'definition_star'
    rule('definition_star' => []).as 'no_definition_yet'
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
    rule('assignment' => 'LPAREN SET! IDENTIFIER expression RPAREN').as 'assignment'
    rule('derived_expression' => 'LPAREN COND cond_clause_plus RPAREN').as 'cond_form'
    rule('derived_expression' => 'LPAREN COND cond_clause_star LPAREN ELSE sequence RPAREN RPAREN').as 'cond_else_form'
    rule('derived_expression' => 'LPAREN LET LPAREN binding_spec_star RPAREN body RPAREN').as 'short_let_form'
    rule('derived_expression' => 'LPAREN LET* LPAREN binding_spec_star RPAREN body RPAREN').as 'let_star_form'

    # As the R7RS grammar is too restrictive, 
    # the next rule was made more general than its standard counterpart
    rule('derived_expression' => 'LPAREN BEGIN body RPAREN').as 'begin_expression'
    rule 'derived_expression' => 'quasiquotation'
    rule('cond_clause_plus' => 'cond_clause_plus cond_clause').as 'multiple_cond_clauses'
    rule('cond_clause_plus' => 'cond_clause').as 'last_cond_clauses'
    rule('cond_clause_star' => 'cond_clause_star cond_clause').as 'cond_clauses_star'
    rule('cond_clause_star' => []).as 'last_cond_clauses_star'
    rule('cond_clause' => 'LPAREN test sequence RPAREN').as 'cond_clause'
    rule('cond_clause' => 'LPAREN test RPAREN')
    rule('cond_clause' => 'LPAREN test ARROW recipient RPAREN').as 'cond_arrow_clause'
    rule('recipient' => 'expression')
    rule('quasiquotation' => 'LPAREN QUASIQUOTE qq_template RPAREN').as 'quasiquotation'
    rule('quasiquotation' => 'GRAVE_ACCENT qq_template').as 'quasiquotation_short'
    rule('binding_spec_star' => 'binding_spec_star binding_spec').as 'multiple_binding_specs'
    rule('binding_spec_star' => []).as 'no_binding_spec_yet'
    rule('binding_spec' => 'LPAREN IDENTIFIER expression RPAREN').as 'binding_spec'
    rule 'qq_template' => 'simple_datum'
    rule 'qq_template' => 'list_qq_template'
    rule 'qq_template' => 'vector_qq_template'
    rule 'qq_template' => 'unquotation'
    rule('list_qq_template' => 'LPAREN qq_template_or_splice_star RPAREN').as 'list_qq'
    rule 'list_qq_template' => 'LPAREN qq_template_or_splice_plus PERIOD qq_template RPAREN'
    rule 'list_qq_template' => 'GRAVE_ACCENT qq_template'
    rule('vector_qq_template' => 'VECTOR_BEGIN qq_template_or_splice_star RPAREN').as 'vector_qq'
    rule('unquotation' => 'COMMA qq_template').as 'unquotation_short'
    rule 'unquotation' => 'LPAREN UNQUOTE qq_template RPAREN'
    rule('qq_template_or_splice_star' => 'qq_template_or_splice_star qq_template_or_splice').as 'multiple_template_splice'
    rule('qq_template_or_splice_star' => []).as 'no_template_splice_yet'
    rule 'qq_template_or_splice_plus' => 'qq_template_or_splice_plus qq_template_or_splice'
    rule 'qq_template_or_splice_plus' => 'qq_template_or_splice'
    rule 'qq_template_or_splice' => 'qq_template'
    rule 'qq_template_or_splice' => 'splicing_unquotation'
    rule 'splicing_unquotation' => 'COMMA_AT_SIGN qq_template'
    rule 'splicing_unquotation' => 'LPAREN UNQUOTE-SPLICING qq_template RPAREN'
  end

  # And now build the grammar and make it accessible via a global constant
  # [Rley::Syntax::Grammar]
  Grammar = builder.grammar
end # module
