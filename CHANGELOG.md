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

