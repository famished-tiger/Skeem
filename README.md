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

```ruby
  require 'skeem'

  schemer = Skeem::Interpreter.new
  scheme_code =<<-SKEEM
    ; Let's define a Scheme variable
    (define foobar (* 2 3 7))

    ; Now retrieve its value
    foobar
  SKEEM
  result = schemer.run(scheme_code)
  puts result.value # => 42
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
