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

