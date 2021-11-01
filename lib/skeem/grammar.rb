# frozen_string_literal: true

# Grammar for Skeem (a subset of Scheme language)
require 'rley' # Load the gem

module Skeem
  ########################################
  # Define a grammar for Skeem
  # The official Small Scheme language grammar is available at:
  # https://bitbucket.org/cowan/r7rs/src/draft-10/rnrs/r7rs.pdf
  # Names of grammar elements are based on the R7RS documentation
  builder = Rley::grammar_builder do
    # Delimiters, separators...
    add_terminals('APOSTROPHE', 'COMMA', 'COMMA_AT_SIGN')
    add_terminals('GRAVE_ACCENT', 'LPAREN', 'RPAREN')
    add_terminals('PERIOD', 'UNDERSCORE', 'ARROW', 'ELLIPSIS')
    add_terminals('VECTOR_BEGIN')

    # Literal values...
    add_terminals('BOOLEAN', 'INTEGER', 'RATIONAL', 'REAL')
    add_terminals('CHAR', 'STRING_LIT', 'IDENTIFIER')

    # Keywords...
    add_terminals('BEGIN', 'COND', 'DEFINE', 'DEFINE-SYNTAX', 'DO')
    add_terminals('ELSE', 'IF', 'INCLUDE', 'LAMBDA', 'LET', 'LET_STAR')
    add_terminals('QUOTE', 'QUASIQUOTE', 'SET!', 'SYNTAX-RULES')
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
    rule('definition' => 'syntax_definition')
    rule('definition' => 'LPAREN BEGIN definition* RPAREN').as 'definitions_within_begin'
    rule('expression' => 'IDENTIFIER').as 'variable_reference'
    rule 'expression' => 'literal'
    rule 'expression' => 'procedure_call'
    rule 'expression' => 'lambda_expression'
    rule 'expression' => 'conditional'
    rule 'expression' => 'assignment'
    rule 'expression' => 'derived_expression'
    rule 'expression' => 'includer'
    rule 'literal' => 'quotation'
    rule 'literal' => 'self-evaluating'
    rule('quotation' => 'APOSTROPHE datum').as 'quotation_short'
    rule('quotation' => 'LPAREN QUOTE datum RPAREN').as 'quotation'
    rule 'self-evaluating' => 'BOOLEAN'
    rule 'self-evaluating' => 'number'
    rule 'self-evaluating' => 'CHAR'
    rule 'self-evaluating' => 'STRING_LIT'
    rule 'self-evaluating' => 'vector'
    rule 'datum' => 'simple_datum'
    rule 'datum' => 'compound_datum'
    rule 'simple_datum' => 'BOOLEAN'
    rule 'simple_datum' => 'CHAR'
    rule 'simple_datum' => 'number'
    rule 'simple_datum' => 'STRING_LIT'
    rule 'simple_datum' => 'symbol'
    rule 'compound_datum' => 'list'
    rule 'compound_datum' => 'vector'
    rule('list' => 'LPAREN datum* RPAREN').as 'list'
    rule('list' => 'LPAREN datum_plus PERIOD datum RPAREN').as 'dotted_list'
    rule('vector' => 'VECTOR_BEGIN datum* RPAREN').as 'vector'
    rule('datum_plus' => 'datum_plus datum').as 'multiple_datums'
    rule('datum_plus' => 'datum').as 'last_datum'
    rule 'symbol' => 'IDENTIFIER'
    rule('procedure_call' => 'LPAREN operator RPAREN').as 'proc_call_nullary'
    rule('procedure_call' => 'LPAREN operator operand+ RPAREN').as 'proc_call_args'
    rule 'operator' => 'expression'
    rule 'operand' => 'expression'
    rule('def_formals' => 'IDENTIFIER*').as 'def_formals'
    rule('def_formals' => 'IDENTIFIER* PERIOD IDENTIFIER').as 'pair_formals'
    rule('lambda_expression' => 'LPAREN LAMBDA formals body RPAREN').as 'lambda_expression'
    rule('formals' => 'LPAREN IDENTIFIER* RPAREN').as 'fixed_arity_formals'
    rule('formals' => 'IDENTIFIER').as 'variadic_formals'
    rule('formals' => 'LPAREN IDENTIFIER+ PERIOD IDENTIFIER RPAREN').as 'dotted_formals'
    rule('syntax_definition' => 'LPAREN DEFINE-SYNTAX keyword transformer_spec RPAREN').as 'syntax_definition'
    rule('body' => 'definition* sequence').as 'body'
    rule('sequence' => 'command* expression').as 'sequence'
    rule('conditional' => 'LPAREN IF test consequent expression? RPAREN').as 'conditional'
    rule 'test' => 'expression'
    rule 'consequent' => 'expression'
    rule 'number' => 'INTEGER'
    rule 'number' => 'RATIONAL'
    rule 'number' => 'REAL'
    rule('assignment' => 'LPAREN SET! IDENTIFIER expression RPAREN').as 'assignment'
    rule('derived_expression' => 'LPAREN COND cond_clause+ RPAREN').as 'cond_form'
    rule('derived_expression' => 'LPAREN COND cond_clause* LPAREN ELSE sequence RPAREN RPAREN').as 'cond_else_form'
    rule('derived_expression' => 'LPAREN LET LPAREN binding_spec* RPAREN body RPAREN').as 'short_let_form'
    # TODO: implement "named let"
    rule('derived_expression' => 'LPAREN LET IDENTIFIER LPAREN binding_spec* RPAREN body RPAREN') # .as 'named_form'
    rule('derived_expression' => 'LPAREN LET_STAR LPAREN binding_spec* RPAREN body RPAREN').as 'let_star_form'

    # As the R7RS grammar is too restrictive,
    # the next rule was made more general than its standard counterpart
    rule('derived_expression' => 'LPAREN BEGIN body RPAREN').as 'begin_expression'
    do_syntax = <<-END_SYNTAX
    LPAREN DO LPAREN iteration_spec* RPAREN
      LPAREN test do_result RPAREN
      rep_command_star RPAREN
END_SYNTAX
    rule('derived_expression' => do_syntax).as 'do_expression'
    rule 'derived_expression' => 'quasiquotation'
    rule('cond_clause' => 'LPAREN test sequence RPAREN').as 'cond_clause'
    rule('cond_clause' => 'LPAREN test RPAREN')
    rule('cond_clause' => 'LPAREN test ARROW recipient RPAREN').as 'cond_arrow_clause'
    rule('recipient' => 'expression')
    rule('quasiquotation' => 'LPAREN QUASIQUOTE qq_template RPAREN').as 'quasiquotation'
    rule('quasiquotation' => 'GRAVE_ACCENT qq_template').as 'quasiquotation_short'
    rule('binding_spec' => 'LPAREN IDENTIFIER expression RPAREN').as 'binding_spec'
    rule('iteration_spec' => 'LPAREN IDENTIFIER init step RPAREN').as 'iteration_spec_long'
    rule('iteration_spec' => 'LPAREN IDENTIFIER init RPAREN').as 'iteration_spec_short'
    rule('init' => 'expression')
    rule('step' => 'expression')
    rule('do_result' => 'sequence?').tag 'do_result'
    rule('keyword' => 'IDENTIFIER')
    rule('includer' => 'LPAREN INCLUDE STRING_LIT+ RPAREN').as 'include'
    rule 'qq_template' => 'simple_datum'
    rule 'qq_template' => 'list_qq_template'
    rule 'qq_template' => 'vector_qq_template'
    rule 'qq_template' => 'unquotation'
    rule('list_qq_template' => 'LPAREN qq_template_or_splice* RPAREN').as 'list_qq'
    rule 'list_qq_template' => 'LPAREN qq_template_or_splice+ PERIOD qq_template RPAREN'
    rule 'list_qq_template' => 'GRAVE_ACCENT qq_template'
    rule('vector_qq_template' => 'VECTOR_BEGIN qq_template_or_splice* RPAREN').as 'vector_qq'
    rule('unquotation' => 'COMMA qq_template').as 'unquotation_short'
    rule 'unquotation' => 'LPAREN UNQUOTE qq_template RPAREN'
    rule 'qq_template_or_splice' => 'qq_template'
    rule 'qq_template_or_splice' => 'splicing_unquotation'
    rule 'splicing_unquotation' => 'COMMA_AT_SIGN qq_template'
    rule 'splicing_unquotation' => 'LPAREN UNQUOTE-SPLICING qq_template RPAREN'
    rule('transformer_spec' => 'LPAREN SYNTAX-RULES LPAREN IDENTIFIER* RPAREN syntax_rule* RPAREN').as 'transformer_syntax'
    rule('transformer_spec' => 'LPAREN SYNTAX-RULES IDENTIFIER LPAREN IDENTIFIER* RPAREN syntax_rule* RPAREN')
    rule('syntax_rule' => 'LPAREN pattern template RPAREN').as 'syntax_rule'
    rule('pattern' => 'pattern_identifier')
    rule('pattern' =>  'UNDERSCORE')
    rule('pattern' =>  'LPAREN pattern* RPAREN')
    rule('pattern' =>  'LPAREN pattern+ PERIOD pattern RPAREN')
    rule('pattern' =>  'LPAREN pattern+ ELLIPSIS pattern* RPAREN')
    rule('pattern' =>  'LPAREN pattern+ ELLIPSIS pattern* PERIOD pattern RPAREN')
    rule('pattern' =>  'VECTOR_BEGIN pattern* RPAREN')
    rule('pattern' =>  'VECTOR_BEGIN pattern+ ELLIPSIS pattern* RPAREN')
    rule('pattern' =>  'pattern_datum')
    rule('pattern_datum' => 'STRING_LIT')
    rule('pattern_datum' => 'CHAR')
    rule('pattern_datum' => 'BOOLEAN')
    rule('pattern_datum' => 'number')
    # rule('pattern_datum' => 'bytevector')
    rule('template' => 'pattern_identifier')
    rule('template' => 'LPAREN template_element* RPAREN')
    rule('template' => 'LPAREN template_element+ PERIOD template RPAREN')
    rule('template' =>  'VECTOR_BEGIN template_element* RPAREN')
    rule('template' =>  'template_datum')
    rule('template_element' =>  'template')
    rule('template_element' =>  'template ELLIPSIS')
    rule('template_datum' =>  'pattern_datum')
    rule('pattern_identifier' => 'IDENTIFIER')
    # Ugly: specialized production rule per keyword...
    rule('pattern_identifier' => 'BEGIN')
    rule('pattern_identifier' => 'COND')
    rule('pattern_identifier' => 'DEFINE')
    rule('pattern_identifier' => 'ELSE')
    rule('pattern_identifier' => 'IF')
    rule('pattern_identifier' => 'INCLUDE')
    rule('pattern_identifier' => 'LAMBDA')
    rule('pattern_identifier' => 'LET')
    rule('pattern_identifier' => 'LET*')
    rule('pattern_identifier' => 'QUOTE')
    rule('pattern_identifier' => 'QUASIQUOTE')
    rule('pattern_identifier' => 'SET!')
    rule('pattern_identifier' => 'UNQUOTE')
    rule('pattern_identifier' => 'UNQUOTE-SPLICING')
  end

  # And now build the grammar and make it accessible via a global constant
  # [Rley::Syntax::Grammar]
  Grammar = builder.grammar
end # module
