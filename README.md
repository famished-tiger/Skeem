# Skeem
[![Linux Build Status](https://travis-ci.org/famished-tiger/Skeem.svg?branch=master)](https://travis-ci.org/famished-tiger/Skeem)
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

## Usage

The __Skeem__ project has just started.  
At this stage, the gem consists of a bare-bones interpreter.

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
Remark: Skeem 0.0.14 doesn't support recursive functions yet.

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

Roadmap:
- Extend language support
- Implement REPL
- Implement an equivalent of [lis.py](http://www.norvig.com/lispy.html)
- Implement an equivalent of [lispy](http://norvig.com/lispy2.html)
- Make it pass the test suite
- Extend the language in order to support [Minikanren](https://github.com/TheReasonedSchemer2ndEd/CodeFromTheReasonedSchemer2ndEd)
- Make it pass all examples from the [Reasoned Schemer](https://mitpress.mit.edu/books/reasoned-schemer-second-edition) book.


Good to know:
Online book: [The Scheme Programming Language (4th Ed.)](https://www.scheme.com/tspl4/). Remark: covers an older version of Scheme.

## Implemented Scheme R7RS features:

### Literals
* Boolean literals: `#t`, `#true`, `#f` and `#false`
* Numeric literals for integers and reals.
* `string` and `identifier` literals

## Other similar Ruby projects
__Skeem__ isn't the sole implementation of the Scheme language in Ruby.  
Here are a few other ones:  
- [Heist gem](https://rubygems.org/gems/heist) -- Probably one of best Scheme implementation in Ruby. Really worth a try. Alas, the [project](https://github.com/jcoglan/heist) seems to be dormant for several years.

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
