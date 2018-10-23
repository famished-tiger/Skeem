# Skeem
|Linux|Windows|  
|:-:|:-:|  
|[![Linux Build Status](https://travis-ci.org/famished-tiger/Skeem.svg?branch=master)](https://travis-ci.org/famished-tiger/Skeem)|[![Windows Build Status](https://ci.appveyor.com/api/projects/status/qs19wn6o6bpo8lm6?svg=true)](https://ci.appveyor.com/project/famished-tiger/skeem)|

[![Gem Version](https://badge.fury.io/rb/skeem.svg)](https://badge.fury.io/rb/skeem)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/famished-tiger/Skeem/blob/master/LICENSE.txt)

__Skeem__ will be an interpreter of a subset of the Scheme programming language.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'skeem'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install skeem


The __Skeem__ project has started recently and at this stage, the gem supports  a small Scheme subset.

## About Scheme

The Scheme programming language is a Lisp dialect that supports multiple paradigms, including functional programming and imperative programming.

### Resources on Scheme  
Here are a few pointers for the Scheme programming language:  
- Wikipedia article on [Scheme](https://en.m.wikipedia.org/wiki/Scheme_\(programming_language\))
- Latest official Scheme standard: [R7RS](https://bitbucket.org/cowan/r7rs-wg1-infra/src/default/R7RSHomePage.md)
#### Online tutorials and books:
- [The Scheme Programming Language, 4th Edition](https://www.scheme.com/tspl4/) by Kent Dybvig. An complete, introductory textbook on Scheme based on the older R5RS standard.
- [Teach Yourself Scheme in Fixnum Days](http://ds26gte.github.io/tyscheme/index.html) by Dorai Sitaram

## Other similar Ruby projects
__Skeem__ isn't the sole implementation of the Scheme language in Ruby.  
Here are a few other ones:  
- [Heist gem](https://rubygems.org/gems/heist) -- Probably one of best Scheme implementation in Ruby. Really worth a try. Alas, the [project](https://github.com/jcoglan/heist) seems to be dormant for several years.

## Usage

### Example 1 (Variable definition)

```ruby
  require 'skeem'

  schemer = Skeem::Interpreter.new

  scheme_code =<<-SKEEM
    ; This heredoc consists of Scheme code...
    ; Let's define a Scheme variable
    (define foobar (* 2 3 7))

    ; Now test its value against a lower value
    (if (> foobar 40) #true #false)
  SKEEM

  # Ask Ruby to execute Scheme code
  result = schemer.run(scheme_code)
  puts result.value # => true

  # The interpreter object keeps the bindings of variable
  # Let's test that...
  scheme_code = '(* foobar foobar)'
  result = schemer.run(scheme_code)
  puts result.value # => 1764
```

### Example 2 (Defining a function)

```ruby
  require 'skeem'

  schemer = Skeem::Interpreter.new

  scheme_code =<<-SKEEM
    ; Let's implement the 'min' function
    (define min (lambda(x y) (if (< x y) x y)))

    ; What is the minimum of 2 and 3?
    (min 2 3)
  SKEEM

  # Ask Ruby to execute Scheme code
  result = schemer.run(scheme_code)
  puts result.value # => 2

  # Let's retry with other values
  scheme_code = '(min 42 3)'
  result = schemer.run(scheme_code)
  puts result.value # => 3
```
### Example 3 (Defining a recursive function)
```ruby
  require 'skeem'

  schemer = Skeem::Interpreter.new
  scheme_code = <<-SKEEM
    ; Compute the factorial of 100
    (define fact (lambda (n)
      (if (<= n 1) 1 (* n (fact (- n 1))))))
    (fact 100)
  SKEEM

  result = schemer.run(scheme_code)
  puts result.value # => 9332621544394415268169923885626670049071596826438162146859296389521759999322991560894146397615651828625369792082722375825118521091686400000000000000000000000
```

## Currently implemented R7RS features
### Data type literals
- Booleans: `#t`, `#true`, `#f`, `#false`
- Of the number hierarchy:  
  `real` (e.g. 2.718, 6.671e-11),  
  `integer` (42, -3)
- Strings: `"Hello, world."`
- Identifiers (symbols): `really-cool-procedure`
- Vectors: `#(1 2 "three")`

### Scheme Expressions
- Variable references
- Procedure calls
- Lambda expressions
- If conditionals
- Definitions

### Standard syntactic forms
#### define  
__Purpose:__ Create a new variable and bind an expression/value to it.  
__Syntax:__   
* (define <identifier\> <expression\>)  
* (define (<variable\> <formals\>) <body\>)

#### if  
__Purpose:__ Conditional evaluation based on a test expression.  
__Syntax:__   
* (if <test\> <consequent\>)  
* (if <test\> <consequent\> <alternate\>)  



#### lambda  
__Purpose:__ Definition of a procedure.  
__Syntax:__   
* (lambda <formals\> <body\>)

### Standard library
This section lists the implemented standard procedures

#### Boolean procedures
* `boolean?`, `not`

#### Numerical operations
* Number-level: `number?`, `real?`, `integer?`, `zero?`, `+`, `-`, `*`, `/`, `=`, `square`
* Real-level: `positive?`, `negative?`, `<`, `>`, `<=`, `>=`, `abs`, `floor-remainder`
* Integer-level: `even?`, `odd?`

#### List procedures
* `list?`, `null?`, `list`, `length`

#### String procedures
* `string?`

#### Symbol procedures
* `symbol?`

#### Vector procedures
* `vector?`, `vector`, `vector-length`, `vector-set!`

#### Input/output procedures
* `newline`

Roadmap:
- Extend language support
- Implement REPL
- Implement an equivalent of [lis.py](http://www.norvig.com/lispy.html)
- Implement an equivalent of [lispy](http://norvig.com/lispy2.html)
- Make it pass the test suite
- Extend the language in order to support [Minikanren](https://github.com/TheReasonedSchemer2ndEd/CodeFromTheReasonedSchemer2ndEd)
- Make it pass all examples from the [Reasoned Schemer](https://mitpress.mit.edu/books/reasoned-schemer-second-edition) book.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/famished-tiger/Skeem.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Copyright
---------
Copyright (c) 2018, Dimitri Geshef.  
__Skeem__ is released under the MIT License see [LICENSE.txt](https://github.com/famished-tiger/Skeem/blob/master/LICENSE.txt) for details.

## Code of Conduct

Everyone interacting in the Skeem project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/famished-tiger/Skeem/blob/master/CODE_OF_CONDUCT.md).
