# File: tokenizer.rb
# Tokenizer for Skeem language (a small subset of Scheme)
require 'strscan'
require_relative 'stoken'

module Skeem
  # A tokenizer for the Skeem dialect.
  # Responsibility: break Skeem input into a sequence of token objects.
  # The tokenizer should recognize:
  # Identifiers:
  # Integer literals including single digit
  # String literals (quote delimited)
  # Single character literal
  # Delimiters: parentheses '(',  ')'
  # Separators: comma
  class Tokenizer
    attr_reader(:scanner)
    attr_reader(:lineno)
    attr_reader(:line_start)

    @@lexeme2name = {
      "'" => 'APOSTROPHE',
      '`' => 'BACKQUOTE',
      '(' => 'LPAREN',
      ')' => 'RPAREN'
    }.freeze

    class ScanError < StandardError; end

    # Constructor. Initialize a tokenizer for Skeem.
    # @param source [String] Skeem text to tokenize.
    def initialize(source)
      @scanner = StringScanner.new(source)
      @lineno = 1
      @line_start = 0
    end

    # @return [Array<SToken>] | Returns a sequence of tokens
    def tokens
      tok_sequence = []
      until @scanner.eos?
        token = _next_token
        tok_sequence << token unless token.nil?
      end

      return tok_sequence
    end

    private

    def _next_token
      skip_whitespaces
      curr_ch = scanner.peek(1)
      return nil if curr_ch.nil? || curr_ch.empty?

      token = nil

      if "()'`".include? curr_ch
        # Delimiters, separators => single character token
        token = build_token(@@lexeme2name[curr_ch], scanner.getch)
      elsif (lexeme = scanner.scan(/#(?:t|f|true|false)((?=\s|[|()";])|$)/))
        token = build_token('BOOLEAN', lexeme) # normalized lexeme
      elsif (lexeme = scanner.scan(/[0-9]+((?=\s|[|()";])|$)/))
        token = build_token('INTEGER', lexeme) # Decimal radix
      elsif (lexeme = scanner.scan(/-?[0-9]+(\.[0-9]+)?((?=\s|[|()";])|$)/))
        token = build_token('REAL', lexeme)
      elsif (lexeme = scanner.scan(/"(?:\\"|[^"])*"/)) # Double quotes literal?
        unquoted = lexeme.gsub(/(^")|("$)/, '')
        token = build_token('STRING_LIT', unquoted)
      elsif (lexeme = scanner.scan(/([\+\-])((?=\s|[|()";])|$)/))
        token = build_token('IDENTIFIER', lexeme) # Plus and minus as identifiers
      elsif (lexeme = scanner.scan(/[a-zA-Z!$%&*\/:<=>?@^_~][a-zA-Z0-9!$%&*+-.\/:<=>?@^_~+-]*/))
        token = build_token('IDENTIFIER', lexeme)
      else # Unknown token
        erroneous = curr_ch.nil? ? '' : scanner.scan(/./)
        sequel = scanner.scan(/.{1,20}/)
        erroneous += sequel unless sequel.nil?
        raise ScanError, "Unknown token #{erroneous} on line #{lineno}"
      end

      return token
    end

    def build_token(aSymbolName, aLexeme)
      begin
        col = scanner.pos - aLexeme.size - @line_start + 1
        pos = Position.new(@lineno, col)
        token = SToken.new(aLexeme, aSymbolName, pos)
      rescue StandardError => exc
        puts "Failing with '#{aSymbolName}' and '#{aLexeme}'"
        raise exc
      end

      return token
    end

    def skip_whitespaces
      pre_pos = scanner.pos

      loop do
        ws_found = false
        found = scanner.skip(/[ \t\f]+/)
        ws_found = true if found
        found = scanner.skip(/(?:\r\n)|\r|\n/)
        if found
          ws_found = true
          @lineno += 1
          @line_start = scanner.pos
        end
        break unless ws_found
      end

      curr_pos = scanner.pos
      return if curr_pos == pre_pos
    end
  end # class
end # module
# End of file
