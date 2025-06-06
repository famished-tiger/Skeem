## [0.2.22] - 2025-03-30
- Dependency updates, minor changes, tested against Ruby 3.4.1.

### Changed
- Files updated to please Rubocop 1.75.1 
- Files `*_spec.rb` updated to please `rubocop-rspec`.

## [0.2.21] - 2022-04-24
- Dependencies updates, minor changes

### Changed
- File `.rubocop.yml` Incorporating new Rubocop cops (up to version 1.28)
- File `grammar.rb`: Refactoring of a rule with grouping parentheses
- File `s_expr_builder` Change to relfect changes in grammar
- File `skeem.gempsec` Updated dependencies; minimal Ruby version is now 2.6+

## [0.2.20] - 2021-11-01
- Code update to cope with changes in `Rley` v. 0.8.08


- File `s_expr_builder.rb`: Refactoring to cope with ? quantifier changes
- File `skeem.gemspec` dependency updated for `Rley` v. 0.8.08

## [0.2.19] - 2021-08-30
- Grammar refactoring: use ?, * and + modifiers in Rley 0.8.03 rules

### Changed
- File `grammar.rb`: Remove redundant rules after introduction of ?, * and + modifiers
- Class `SkmBuilder`: Removal of useless methods after removal of their rule counterpart



## [0.2.18] - 2021-08-29
- Minor refactoring for Rley 0.8.03
- Code restyling to please rubocop 1.19.1.

### Changed
- File `.rubocop.yml` updated with newer Rubocop cops
- File `grammar.rb`: Calling `Rley::grammar_builder`, replace `LET*` token by `LET_STAR`
- Other files changed to get rid of Rubocop offences

## [0.2.17] - 2020-05-09
- Updated `.rubocop.yml` file. 
- Code restyling to please rubocop 0.8.0. 

## [0.2.16] - 2019-08-18
- Code refactoring to use string frozen magic comments (as a consequence, srl_ruby runs only on Rubies 2.3 or newer).  
- Code restyling to please rubocop 0.7.40. 

## [0.2.15] - 2019-07-02
- Added a basic command-line and console interface for Skeem interpreter.
- Added procedures: `display!`, `newline`, `make-list`

### Added
- `bin/skeem` The CLI and REPL console implementation for Skeem 
- `bin/cubic.skm`: A sample defining a procedure that computes the cube of a number.
- `bin/hello-world.skm`: The initiatic programming example

### Changed
- File `primitive_builder.rb` Implementation of primitive procedures `newline`, `make-list`
- File `base.skm` Added implementation of `newline` procedure.
- File `README.md` vastly reorganized and introducing the new command line.

### Removed
- Bundler-generated files `bin/console`, `bin/setup`

## [0.2.14] - 2019-06-29
- Added derived expression `do` as an imperative iteration form. 
- Added procedures: `vector-set!`

### Added
- Class `DoExpression` for the representation of the do loop expression
- Class `SkmDelayedUpdateBinding` for implementation delayed updates of bindings

### Changed
- File `tokenizer.rb` Added new keyword `do`
- File `grammar.rb` Added rules for the `do` expression syntax
- File `primitive_builder.rb` Implementation primitive procedure `vector-set!`
- File `README.md` Updated to reflect additions.

### Fixed
- Method `DatumDSL#to_datum` now supports an `SkmUndefined` input argument.

## [0.2.13] - 2019-06-22
- Skeem now accepts integers in hexadecimal notation
- Added procedures: `char->integer`, `integer->char`, `char=?`, `char<?`, `char>?`, `char<=?`, `char>=?`

### Changed
- Class Tokenizer updated to recognize integer literals in hexadecimal notation.
- `DatumDSL#char(aLiteral): added conversion of char literal into SkmChar.
- File `grammar.rb` Added a rule to derive a simple datum from a character literal 
- File `primitive_builder.rb` Implemented primitive procedures `char->integer`, `integer->char`, `char=?`, `char<?`, `char>?`, `char<=?`, `char>=?`
- File `README.md` Added mentions to new procedures.
- File `tokenize_spec.rb: added tests for haxadecimal integers.
- File `primitive_builder_spec.rb`: Added tests for new procedures. 


## [0.2.12] - 2019-06-19
- Skeem now supports character datatype
- Added procedures: `boolean=?`, `char?`, `string`, `make-string`, `reverse`
  
### Added
- Class `SkmChar`
- Method `SkmPair#proper?` to check whether a pair/list is a proper one.

### Changed
- Class Tokenizer updated to recognize character literals (specified by name, by hexadecimal code, escaped).
- File `grammar.rb` Added new terminal CHAR and one derivation rule
- File `primitive_builder.rb` Implemented primitive procedures `boolean=?`, `char?`, `string`, `make-string`, `reverse`
- File `README.md` Added mentions to new procedures.
- File `tokenize_spec.rb`DRYing the spec file.`
- File `primitive_builder_spec.rb`: Added tests for new procedures.

## [0.2.11] - 2019-06-16
- Added procedures: `gcd`, `lcm`, `numerator`, `denominator`, `floor`, `ceiling`, `truncate`,
  `round`.

### Changed
- File `interpreter_spec.rb`: Refactoring by DRYing code
- File `primitive_builder_spec.rb`: Refactoring by DRYing code
- File `base.skm` added implementation of  `truncate`
- File `primitive_builder.rb` Implemented primitive procedures `gcd`, `lcm`, `numerator`, `denominator`, `floor`, `ceiling`, `round`.
- File `README.md` Added mentions to new procedures.

## [0.2.10] - 2019-06-15
- Skeem now supports rational numbers (fractions)
- Added procedures: `max`, `min`, `floor/`, `floor-quotient`, `floor-remainder`, `truncate/`, `truncate-quotient`,
  `truncate-remainder`, `quotient`, `remainder`, `modulo`

### Added
- `DatumDSL#rational` conversion method

### Changed
- `DatumDSL#to_datum(aLiteral): added conversion of literal rational into rational value.
 - Class Tokenizer updated to recognize rational numbers.
- File `grammar.rb` Added new terminal RATIONAL and rule deriving number from rational
- File `primitive_builder.rb` Implemented primitive procedures floor/ and truncate/
- Class `SkmInteger` now inherits from `SkmRational` class
- File `base.skm` added implementation of  `floor-quotient`, `floor-remainder`, `truncate-quotient`, 
  `truncate-remainder`, `quotient`, `remainder`, `modulo`
 - Test suite file `base_tests.scm` expanded.
 - File `README.md` Added mentions to new procedures.

### Fixed
- File `primitive_builder.rb` Fixed and extended implementation of `/`procedure

## [0.2.09] - 2019-06-10
- New procedures: `complex?`, `exact-integer?`
- Support for `#| ... |#` block comments (including nesting)

### Added
- File `base.skm`: Added integer number predicate `exact-integer?`
- File `primitive_builder.rb`: Added numeric type predicate `complex?`
- New method `Tokenizer#skip_block_comment` to handle "| ... |#" comments (including their nesting)
- New folder `test_skeem` containing a test suite in `Skeem`

### Changed
- Method 'PrimitiveProcedure#do_call' whenever possible, the arguments are evaluated before executing the primitive.
- File `primitive_builder.rb`: Lambda expression refactoring as most argument evaluations became redundant.
- Method `Tokenizer#_next_token` numeric literals with only zero(es) in their fractional part are implicitly converted to integers `3.0` => 3 
- Method `Tokenizer#skip_whitespaces` refactoring & detection of block comments 

### Fixed
- File `base.skm`: predicate `positive?` returned #t when argument was zero. Now: (positive? 0) returns #f as expected.

### Removed
- Empty method `PrimitiveBuilder#add_binding` removed.


## [0.2.08] - 2019-06-02
- New standard procedures implemented: `assq`, `assv`

### Added
- File `primitive_builder.rb`. New methods for implementing `assq`, `assv`

### Changed
- File `README.md` Added mentions to new procedures.

### Removed
- Superseded class `SkmList` removed.


## [0.2.07] - 2019-05-31
- New standard procedures implemented: `list-copy`, `procedure?`, `apply` and `map`

### Added
- File `primitive_builder.rb`. New methods for implementing `list-copy`, `procedure?`, `apply` and `map`

### Changed
- File `README.md` Added mentions to new procedures. 

## [0.2.06] - 2019-05-30
- NEW Special `cond` (= condional) form implemented. Supports `else` alternative and arrow (=>) syntax.
- FIX Corner case in procedure `append`.

### Added
- Class `SkmConditional`. Internal representation of `cond`forms.

### Changed
- Class `Skeem::Tokenizer`. Added keywords `cond`, `else` and `=>` separator.
- Method `Tokenizer#_next_token` updated to accept new keywords and arrows `=>`
- File `grammar.rb`: Added new terminals and new production rules for parsing the `cond` form
- File `s_expr_builder.rb`: Added new methods for building parse tree of `cond` forms
- File `interpreter_spec.rb`: Added tests for `cond`form.
- File `README.md` Updated for `cond` form. Added fifth example illustrating the `cond` form.

### Fixed
- Method `Primitive#create_append`: test case (append '() 'a)) failed to return a (as identifier)


## [0.2.05] - 2019-05-26
- Passing more standard Scheme tests, `append` procedure implemented.

### Added
- File `primitive_builder.rb`: Added implementation for standard procedure `append`.
- Class `LambdaRep`: represents a parse tree of a lambda expression.

### Changed
- File `grammar.rb`: Changed a grammar rule for (begin ...) expression because R7RS was too restrictive compared to main implementations.
- Class `SkmBuilder` several method updates (e.g. `reduce_alt_definition`)

### Removed
- Class `Environment` superseded by class `SkmFrame`

## [0.2.04] - 2019-04-29
- Support for local definitions [initial]

### Changed
- File `grammar.rb` Added one production rule for third `begin` form syntax.
- Method `SkmBuilder#reduce_begin_cmd` added to implement semantic action for new `begin...` production rule.
- File `README.md` Added a couple of links for additional Scheme resources.


### Removed
- Method `SkmLambda#evaluate_defs` replaced by homonymous method in `SkmProcedureExec` class.

## [0.2.03] - 2019-04-26
### Changed
- File `README.md` added new example with procedures holding each their local states.
### Fixed
- The nesting of a lambda expression nested in a let construct caused an aliasing of the bindings.

## [0.2.02] - 2019-04-20
### Added
- Skeem now supports 'let*' local binding construct

## [0.2.01] - 2019-04-19
### Added
- Skeem now supports 'let' local binding construct

## [0.2.00] - 2019-04-14
### Major refactoring

## [0.1.03] - 2019-01-15
### Added
- File `base.skm` implementation of list procedures: `caar`, `cadr`, `cdar`, `cddr`

### Changed
- File `interpreter_spec.rb` added spec examples to test the new procedures.
- File `README.md` added allusion to new procedures?

## [0.1.02] - 2019-01-13
### Added
- File `primitive_builder.rb` implementation of: `equal?`, `make-vector`, `symbol->string` procedures.

### Changed
- File `.travis.yml` Added newer Ruby versions and more environments in "Allowed failures" because of Bundler issue.
- File `README.md` updated to reflect currently implemented features.
- Class `SkmUndefined` uses now the Singleton pattern.

### Fixed
- File `skeem.gemspec` Make dependency on Bundler gem depends on the Ruby version.
- Method `SkmElement#eqv?` was missing. Method is now implemented.
- Class `PrimitiveProcedure` was unable to cope with procedures with a bounded range of arity.

## [0.1.01] - 2019-01-01
- Fixes, added 'set-car!', 'set-cdr!' standard Scheme procedures.

### Added
- File `primitive_builder.rb` implementation of: `set-car!`, `set-cdr!` list procedures.

### Changed
- Methods `SkmBuilder#reduce_quotation_short`, `SkmBuilder#reduce_quotation` added optimization for quoted literal data.


## [0.1.00] - 2018-12-28
- Version bumped because lists are re-implemented in a way to closer to historical Scheme/Lisp.
- A lot of internal refactoring after list re-implementation...

### Added
- File `primitive_builder.rb` implementation of: `pair?`, `car`, `cdr`, `cons`, `list->vectors` list procedures.
- File `primitive_builder.rb` implementation of: `vector->list` vector procedures.

### Changed 
- Class `SkmList` is now deprecated and being replaced by `SkmPair`nodes.  
- Class `SkmElementVisitor` supports new visit events: `visit_empty_list` and `visit_pair`


## [0.0.28] - 2018-12-10
- Nasty bug fix: interpreter was'nt able to retrieve data argument deep in call stack.

### Added
- Method `Environment#inspect`

### Fixed
- Method `SkmDefinition#call` now accepts variable references that refer to a lambda or a primitive procedure.
- Method `SkmLambda#evaluate_sequence` failed when argument value came from a caller deep in call stack?
- Added a specific test in `interpreter_spec.rb`

## [0.0.27] - 2018-11-25
### Fixed
- The interpreter failed with second-order lambdas (lambda expression that contains another lambda)
- Added a specific test in `interpreter_spec.rb`

## [0.0.26] - 2018-11-25

### Added
- Procedure `eqv?` 
- Procedure `assert`
- Class `Runtime`, call stack added.
- Class `ProcedureCall`, attribute `call_site` added. It contains the location of the call (line and column)

### Changed 
- File `primitive_builder.rb` implementation of: not procedure removed, `not` is now implemented in `base.skm`.
- Method `Tokenizer#build_token` updated to remain compatible with new Rley (> 0.7.x)) 

### Removed
- File `stoken.rb`: Class `SkmToken` is no more necessary.

## [0.0.25] - 2018-11-11
Aliasing of procedures with 'set!' is supported.

### Added 
- Procedures `string=?`, `symbol=?`

## [0.0.24] - 2018-11-08
Many internal refactoring, augmented spec files base, initial quasiquotation implementation.  

### Added
- File `primitive_builder.rb` implementation of standard: `string->length`
- File `datum_dsl.rb` to implement an internal DSL for building literal data elements.
- Files `tokenizer.rb`, `grammar.rb`, `class SExprBuilder` Added support for quasiquotation: (quasiquote foo) or `foo and unquoting

### Changed
- File `README.md` udpated to reflect currently implemented features.

## [0.0.23] - 2018-10-24
### Added
- File `primitive_builder.rb` implementation of: standard `or`, `string->symbol`, `number->string`, `string-append` procedures.

### Changed
- File `README.md` udpated to reflect currently implemented features.

### Fixed
- Method `Convertible#to_skm` Now converts String argument into `SkmString` and raises an exception when unable to convert.

## [0.0.22] - 2018-10-23
### Added
- Class `SkmBuilder`added support for list datum.
- File `primitive_builder.rb` implementation of: standard `and` procedure.

### Fixed
- File `interpreter_spec.rb` Added test example of list quotation.

## [0.0.21] - 2018-10-22
### Added
- Added support for alternative `define` syntax.
- File `primitive_builder.rb` implementation of: standard `vector-ref` procedure.
- Added `SkmQuotation#inspect`, `SkmVector#inspect` method

### Changed
- File `README.md` added sub-section with links for Scheme language.

### Fixed
- Method `Convertible#to_skm` now returns a SkmElement-like object without attempting a convertion.

## [0.0.20] - 2018-10-21
### Added
- Added support for quotation: (quote foo) or 'foo
- Added support for vectors #( 1 2 3 "foo")
- Added primitive procedures `vector?`, `vector`, `vector-length`  

### Changed
- File `README.md` enhanced with detailed implementation status.
- Class `PrimitiveBuilder` in addition to new Skeem procedures, the class was vastly refactored.
- Class `Tokenizer` extended to cope with quotation and vectors.

## [0.0.19] - 2018-10-15
Added primitive procedures `list?`, `null?`, `length`

### Added
- File `primitive_builder.rb` implementation of: `list?`, `null?`, `length` procedures.
- File `primitive_builder_spec.rb` spec examples for: `list?`, `null?`, `length` procedures.

### Fixed
- Method `SkmLambda#bind_locals` Fix: a variadic procedure with no argument provided, should have empty list as actual argument.
- File `interpreter_spec.rb` Added test case for calling `list` procedure without argument.

## [0.0.18] - 2018-10-14
Reworked procedure argument-passing. 

### Added
- Classes `SkmArity`, `SkmFormals` implement the core argument counting checks.

### Changed
- Class `PrimitiveProcedure` vastly reworked to support Scheme's argument passing convention.
- Class `PrimitiveBuilder` primitive procedures now check the number of arguments.
- Class `SkmLambda` vastly reworked to support Scheme's argument passing convention. 

### Fixed
- Method `Tokenizer#skip_whitespaces` Fix: comment lines were ignored in line counting.
- Method `Tokenizer#_next_token` Fix: mistake in regex for period (dot) recognition.

## [0.0.17] - 2018-10-06
- Fix: now support calls of anonymous lambda procedures.

### Fixed
- Method `SkmProcedureCall#evaluate` Fix: no procedure name lookup for anonymous ones!

## [0.0.16] - 2018-10-06
- Added built-in procedures `odd?`, `even?`, `square`, and `floor-remainder` (`modulo`).
- Supports procedures without argument.
- Implements second syntax form for variable definition. 
- Fixed nasty bug when same variable name used in nested procedure calls.

### Added
- Method `Environment#depth to count the nesting levels
- File `primitive_builder.rb` implementation of: `odd?`, `even?`, `square`, `floor-remainder`, `modulo` procedures.
- File `grammar.rb` rule for second syntax form for variable definition.
- File `grammar.rb` rule for calling procedures without argument.

### Fixed
- Method `SkmDefinition#evaluate` Infinite recursion when a variable, say x, referred to a variable with same name in outer scope.

## [0.0.15] - 2018-09-30
Recursive functions are now supported.  
Interpreter pre-loads a Scheme file with standard procedures (zero?, positive?, negative?, abs)

### Added
- File `base.skm` with standard Scheme procedures `zero?`, `positive?`, `negative?`, `abs`

### Changed
- Class `Interpreter#initialize` now execute a Scheme file containing a number of standard procedures.
- File `README.md` Added third demo snippet showing example of recursive lambda function.

### Fixed
- Method `SkmLambda#bind_locals` now execute any procedure call in argument list before executing the lambda itself.

## [0.0.14] - 2018-09-23
Added `lambda` (anonymous function). This is an initial implementation that doesn't support recursion yet.

### Added
- Class `SkmLambda` for representing a specific definition.

### Changed
- Class `Environment`. Now supports the nesting of environments. If an environment doesn't find a variable, then it forwards the serach to the outer environment.
- File `grammar.rb` Added syntax rules for lambda expression.
- Class `Runtime` added methods `nest` and `unnest` that adds or removes an nested environment.
- Class `SkmBuilder`. Added method to implement the semantic action for `lambda` expressions.
- Class `Tokenizer` Added keyword `lambda`
- File `README.md` Added demo snippet with example of lambda expression.
- Files `*_spec.rb` Added more tests. Skeem passes the 100 'RSpec examples' mark.

## [0.0.13] - 2018-09-18
Added primitive `if` (conditional form)

### Added
- Class `SkmCondition` for representing a specific conditional.

### Changed
- File `grammar.rb` Added syntax rules for conditional expression.
- Class `SkmBuilder`. Added method to implement the semantic action for `if`.
- File `interpreter_spec.rb` added tests for `if`.
- File `README.md` Changed demo snippet with example of conditional expression.

## [0.0.12] - 2018-09-17
Added primitive `define` and variable reference

### Added
- Class `SkmDefinition` for representing a specific definition.
- Class `SkmVariableReference` for representing a variable reference (i.e. retrieving its value)
- Module `Convertible` implementing utility methods for converting "native" Ruby objects into their Skeem counterpart.
- Class `SkmBuilder`. Added methods to implement the semantic actions for `define` and variable reference.
- File `interpreter_spec.rb` added tests for `define` and variable reference.

### Changed
- File `README.md` Changed demo snippet with example of variable definition and variable reference.

## [0.0.11] - 2018-09-16
Added primitive procedures: `=`, `<`, `>`, `>=`, `<=`

### Added
- Class `PrimitiveBuilder`. Added methods to implement the comparison operators `=`, `<`, `>`, `>=`, `<=`
- File `interpreter_spec.rb` added tests for `<`, `>`, `>=`, `<=`

## [0.0.10] - 2018-09-15
Added primitive procedures: 'boolean?', 'string?', 'symbol?', and 'not' 

### Added
- Class `PrimitiveBuilder`. Added methods to implement the predicates 'boolean?', 'string?', 'symbol?', and 'not'
- File `interpreter_spec.rb` added tests for 'boolean?', 'string?', 'symbol?'

### Changed
- Class hierarchy `SExprElement`. Prefix `SExpr` in class names changed into 'Skm'

### Fixed
- Method `PrimitiveBuilder#create_minus` When '-' has only one argument then it means sign change.

## [0.0.9] - 2018-09-15
Added primitive procedures: 'number?', 'real?', 'integer?'.

### Added
- Class `PrimitiveBuilder`. Added methods to implement the predicates number?, real?, integer?
### Changed
- Class hierarchy `SExprElement`. Prefix `SExpr` in class names changed into 'Skm'

## [0.0.8] - 2018-09-13
Added primitive operators: '-', '*', '/' operators.

### Added
- Class `PrimitiveBuilder`. Added methods to implement the arithmetic operators - (subtraction), * (product), / (division)
- Class `SExprList`. Class refactoring
- Class `PrimitiveFunc` Internal representation of primitive functions.

### Changed
- File `interpreter_spec.rb` Added tests for arithmetic expressions.
- File `README.md` Changed demo snippet with example of arithmetic expression.

## [0.0.7] - 2018-09-12
Proof of concept of a primitive function: '+' operator.
Demo works but code needs some polishing and testing.

### Added
- Class `Environment`. Holds a mapping between symbol names and their associated value.
- Class `PrimitiveBuilder`. Builder class that seeds the default environment with primitive functions (now, limited to '+')
- Class `PrimitiveFunc` Internal representation of primitive functions.
- Class `Runtime`. Holds all context data of the Skeem interpreter.
- Methods `SExprBuilder#reduce_proc_call`, `SExprBuilder#reduce_multiple_operands`, SExprBuilder#reduce_last_operand

### Changed
- Class `Tokenize` Added support for Scheme semi-colon comments.
- File `grammar.rb` Added syntax rules for procedure calling.
- File `s_expr_nodes.rb` Class and code refactoring.
- File `README.md` Changed demo snippet with example plus operator.


## [0.0.6] - 2018-09-01
Initial (minimalistic) interpreter implementation.
### Added
- Class `Interpreter`.
- Spec file `interpreter_spec.rb` initial test suite for the interpreter.

### Changed
- File `README.md` Udpates, sample code snippet added, link to other similar project `heist`.
- Method `SExprTerminalNode#interpret` returns self instead of the `value` attribute.


## [0.0.5] - 2018-08-30
Parser now generates correct parse trees for expressions consisting of a single literal.

### Fixed
- Class`Tokenizer` The regexp for real numbers was too restricitive: it didn't recognize real numbers without fractional part.


## [0.0.4] - 2018-08-29
### Added
- File `s_expr_nodes.rb` with initial implementation of `SExprTerminalNode` classes.

### Changed
- Class`Tokenizer` converts literal into Ruby "native" objects


## [0.0.3] - 2018-08-25
### Added
- File `grammar.rb` with minimalist grammar.
- Initial `Parser` class commit

### Changed
- Class`Tokenizer` recognizes `define` keyword
- Spec file `Tokenizer_spec.rb` expanded with more tests.

## [0.0.2] - 2018-08-25
### Changed
- Class`Tokenizer` improved, does recognize delimiters, booleans, integers, real numbers, strings, and identifiers.
- Spec file `Tokenizer_spec.rb` expanded with more tests.

## [0.0.1] - 2018-08-25
### Added
- Initial `Tokenizer` class commit

## [0.0.0] - 2018-08-24
### Added
- Initial Github commit

## Unreleased
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

