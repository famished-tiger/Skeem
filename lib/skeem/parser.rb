# frozen_string_literal: true

require_relative 'tokenizer'
require_relative 'grammar'
require_relative 's_expr_builder'

module Skeem
  class Parser
    attr_reader(:engine)

    def initialize
      # Create a Rley facade object
      @engine = Rley::Engine.new do |cfg|
        cfg.diagnose = true
        cfg.repr_builder = SkmBuilder
      end

      # Step 1. Load Skeem grammar
      @engine.use_grammar(Skeem::Grammar)
    end

    # Parse the given Skeem expression into a parse tree.
    # @param source [String] Skeem expression to parse
    # @return [ParseTree] A regexp object equivalent to the Skeem expression.
    # @example Defining a function that computes the area of a circle
    #   source = "(define circle-area (lambda (r) (* pi (* r r))))"
    #   regex = Skeem::parse(source)
    def parse(source)
      lexer = Skeem::Tokenizer.new(source)
      result = engine.parse(lexer.tokens)

      unless result.success?
        # Stop if the parse failed...
        line1 = "Parsing failed\n"
        line2 = "Reason: #{result.failure_reason.message}"
        raise StandardError, line1 + line2
      end

      return engine.to_ptree(result)
    end
  end # class
end # module
