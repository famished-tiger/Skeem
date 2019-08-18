# Skeem
|Linux|Windows|  
|:-:|:-:|  
|[![Linux Build Status](https://travis-ci.org/famished-tiger/Skeem.svg?branch=master)](https://travis-ci.org/famished-tiger/Skeem)|[![Windows Build Status](https://ci.appveyor.com/api/projects/status/qs19wn6o6bpo8lm6?svg=true)](https://ci.appveyor.com/project/famished-tiger/skeem)|

[![Gem Version](https://badge.fury.io/rb/skeem.svg)](https://badge.fury.io/rb/skeem)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/famished-tiger/Skeem/blob/master/LICENSE.txt)

__Skeem__ is a Scheme language interpreter written in Ruby.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'skeem'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install skeem


The __Skeem__ project is WIP and currently the gem supports a subset of the __Scheme__ language.  
If you're not familiar to Scheme, the section [About Scheme](#about-scheme) contains a number of interesting pointers.


## Usage
Once the gem is installed, the `skeem` executable can be used.
It allows to run the interpreter from a REPL console or from the command line.
Another way to interact with the Skeem interpreter is to embed it in your Ruby code.

### Launching a REPL session
To start a REPL (Read-Eval-Print-Loop) session, just type:
```
  skeem
```

Skeem displays a greeting, a prompt and then waits for your input:
```
Welcome to Skeem 0.2.16.
>
```

Now that we know that `Skeem` is well alive, let's kick it...
We begin with the ritual 'Hello world' example, by typing after the __>__ prompt:
```
(display "Hello, world")
```

Skeem then replies:
```
Hello, world
Skeem::SkmUndefined
```

This works as expected except, maybe, for the last line. It can be easily explained if one knows
that the return value of the `display` procedure is undefined in standard Scheme.  
Internally Skeem, implements such undefined result as a `Skeem::Undefined`instance.

To give some taste of things, here is an excerpt from a REPL session:
```
> (+ 4 (* 5 6))
34
> (define x 6)
6
> (+ (* 5 x x) (* 4 x) 3)
207
> (/ 21 5)
21/5
> (/ 21.0 5)
21/5
```

#### Terminating a REPL session
To exit a REPL session, call the `exit` procedure as follows:
```
(exit)
```

### Running a Skeem file
To run a Scheme file:

```
  skeem path/to/some-file.skm
```

By the way, the `/bin` folder of the `skeem` gem contains a couple of Skeem sample files.

## Embed Skeem in your Ruby app
This is the third way for Rubyists to interact with Skeem by integrating it directly in their Ruby code.

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
    (define min (lambda (x y) (if (< x y) x y)))

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
### Example 4 (Defining a procedure that holds its own environment)
```ruby
  require 'skeem'

  schemer = Skeem::Interpreter.new
  scheme_code = <<-SKEEM
  (define make-counter
    ;; create a procedure that will bind count and
    ;; return a new procedure that will iself increment the
    ;; variable and return its newest value
    (lambda ()
       (let ((count 0))
          (lambda ()
             (set! count (+ count 1))
             count))))

  (define c1 (make-counter))
  (define c2 (make-counter))
  (define c3 (make-counter))

  ;; Notice how each procedure keeps track of its "own" counter.
  (c1) ; => 1
  (c2) ; => 1
  (c1) ; => 2
  (c3) ; => 1
  (c1) ; => 3
  SKEEM

  result = schemer.run(scheme_code)
  puts result.last.value # => 3
```

### Example 5 (Conditional branching)

```ruby
  require 'skeem'

  schemer = Skeem::Interpreter.new

  scheme_code =<<-SKEEM
    ; Let's implement the 'signum' function
    (define signum (lambda (x)
       (cond
         ((positive? x) 1)
         ((zero? x) 0)
         (else -1))))

    (signum -3)
  SKEEM

  result = schemer.run(scheme_code)
  puts result.value # => -1
```


## Currently implemented R7RS features
### Comments
- Semi-colon delimited comments: `; This comment stops at the end of line`
- Block `#| ... |#` comments

### Data type literals
- Booleans: `#t`, `#true`, `#f`, `#false`  
- Characters: `#\a`, `#\newline`, `#\x3BB`
- Of the number hierarchy:  
  `real` (e.g. 2.718, 6.671e-11),  
  `rational` (e.g. 22/7, 1/137, -13/41)  
  `integer` (42, -3 also in hexadecimal notation: #x3af)
- Lists (quoted) : '(1 two "three")
- Strings: `"Hello, world."`
- Identifiers (symbols): `really-cool-procedure`
- Vectors: `#(1 2 "three")`

### Scheme Expressions
- Constant literals
- Quotations
- Quasiquotation (without unquote-splicing)
- Variable references
- Procedure calls
- Lambda expressions
- Conditionals (`if`, `cond`)
- Definitions
- Assignments
- Iteration (`do`)
- Control procedures

### Standard library
This section lists the procedures following closely the official [Revised7 Report on the Algorithmic Language](https://bitbucket.org/cowan/r7rs/src/draft-10/rnrs/r7rs.pdf) standard.

#### Equivalence predicates
* `eqv?`, `equal?`

#### Boolean procedures
* `boolean?`, `boolean=?`, `and`, `or`,  `not`

#### Character procedures
* `char?` `char->integer`, `char=?`, `char<?`, `char>?`,`char<=?`, `char>=?`

#### Numerical operations
* Number-level: `number?`, `complex?`, `real?`, `rational?`, `integer?`, `zero?`,  
`exact?`, `inexact?`, `exact-integer?` , `+`, `-`, `*`, `/`, `=`, `square`, `number->string`
* Real-level: `positive?`, `negative?`, `<`, `>`, `<=`, `>=`, `abs`, `max`, `min`,  
 `floor/`, `floor-quotient`, `floor-remainder`, `truncate/`, `truncate-quotient`,  
`truncate-remainder`, `quotient`, `remainder`, `modulo`, `gcd`, `lcm`, `numerator`,  
`denominator`, `floor`, `ceiling`, `truncate`, `round`
* Integer-level: `even?`, `odd?`, `integer->char`

#### List procedures
* `list?`, `null?`, `pair?`, `append`, `car`, `cdr`, `caar`, `cadr`, `cdar`, `cddr`,  
`cons`,  `make-list`, `length`, `list`, `list-copy`, `list->vector`, `reverse`,  
`set-car!`, `set-cdr!`, `assq`, `assv`

#### String procedures
* `string?`, `string=?`, `string`, `make-string`, `string-append`, `string-length`, `string->symbol`

#### Symbol procedures
* `symbol?`, `symbol=?`, `symbol->string`

#### Vector procedures
* `vector?`, `make-vector`, `vector`, `vector-length`, `vector-set!`, `vector->list`

#### Control procedures
* `procedure?`, `apply`, `map`

#### Input/output procedures
* `display`, `newline`

#### Non-standard procedures
* `assert`


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

#### quote  
__Purpose:__ Quoting an expression (leave it unevaluated).  
__Syntax:__   
* (quote <datum\>)
* '<datum\>

#### set!  
__Purpose:__ Assign to an existing variable an expression/value to it.  
__Syntax:__   
* (set! <identifier\> <expression\>)  

### Derived expressions
#### cond  
__Purpose:__ Define one or more branchings.  
__Syntax:__   
* (cond (<test\> <consequent\>)\+)  
* (cond (<test\><consequent\>)* (else <alternate\>))

#### do
__Purpose:__ Sequential iteration  
__Example__
```scheme
(do (
    (vec (make-vector 5))
    (i 0 (+ i 1)))
  ((= i 5) vec)
  (vector-set! vec i i)) ; => #(0 1 2 3 4)
```

#### let  
__Purpose:__ Define one or more variable local to the block.  
__Syntax:__   
* (let (<binding_spec\*\>) <body\>)


#### let*  
__Purpose:__ Define one or more variable local to the block.  
__Syntax:__   
* (let* (<binding_spec\*\>) <body\>)


## Roadmap
- Implement an equivalent of [lis.py](http://www.norvig.com/lispy.html)
- Implement an equivalent of [lispy](http://norvig.com/lispy2.html)
- Make it pass the test suite
- Extend the language in order to support [Minikanren](https://github.com/TheReasonedSchemer2ndEd/CodeFromTheReasonedSchemer2ndEd)
- Make it pass all examples from the [Reasoned Schemer](https://mitpress.mit.edu/books/reasoned-schemer-second-edition) book.

## About Scheme

The Scheme programming language is a Lisp dialect that supports multiple paradigms, including functional programming and imperative programming.

### Resources on Scheme  
Here are a few pointers for the Scheme programming language:  
- Wikipedia article on [Scheme](https://en.m.wikipedia.org/wiki/Scheme_\(programming_language\))
- Latest official Scheme standard: [R7RS](https://bitbucket.org/cowan/r7rs-wg1-infra/src/default/R7RSHomePage.md)
#### Online tutorials and books:
- [The Scheme Programming Language, 4th Edition](https://www.scheme.com/tspl4/) by Kent Dybvig. A complete, introductory textbook on Scheme based on the older R5RS standard.
- [Teach Yourself Scheme in Fixnum Days](http://ds26gte.github.io/tyscheme/index.html) by Dorai Sitaram
- [Yet Another Scheme Tutorial](http://www.shido.info/lisp/idx_scm_e.html) by Shido Takafumi
- [An Introduction to Scheme and its Implementation](http://www.cs.utexas.edu/ftp/garbage/cs345/schintro-v14/schintro_toc.html) by Paul R. Wilson


## Other Scheme implementations in Ruby
__Skeem__ isn't the sole implementation of the Scheme language in Ruby.  
Here are a few other ones:  
- [Heist gem](https://rubygems.org/gems/heist) -- Probably one of best Scheme implementation in Ruby. Really worth a try. Alas, the [project](https://github.com/jcoglan/heist) seems to be dormant for several years.
- [Schemerald gem](https://rubygems.org/gems/schemerald). The last commit for the [project](https://github.com/vntzy/schemerald) is October 2017.

- [rubic gem](https://rubygems.org/gems/rubic). The last commit for the [project](https://github.com/notozeki/rubic) is June 2015.

- [RLisp](https://github.com/davydovanton/rlisp) ...Simple scheme interpreter written in ruby
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/famished-tiger/Skeem.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Copyright
---------
Copyright (c) 2018-2019, Dimitri Geshef.  
__Skeem__ is released under the MIT License see [LICENSE.txt](https://github.com/famished-tiger/Skeem/blob/master/LICENSE.txt) for details.

## Code of Conduct

Everyone interacting in the Skeem project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/famished-tiger/Skeem/blob/master/CODE_OF_CONDUCT.md).
