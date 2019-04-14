# File: tokenizer.rb
# Tokenizer for Skeem language (a small subset of Scheme)
require 'strscan'
require 'rley'

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
      '`' => 'GRAVE_ACCENT',
      '(' => 'LPAREN',
      ')' => 'RPAREN',
      '.' => 'PERIOD',
      ',' => 'COMMA',
      ',@' =>  'COMMA_AT_SIGN',
      '#(' => 'VECTOR_BEGIN'
    }.freeze

    # Here are all the Scheme keywords (in uppercase)
    @@keywords = %w[
      BEGIN
      DEFINE
      IF
      LAMBDA
      QUASIQUOTE
      QUOTE
      SET!
      UNQUOTE
      UNQUOTE-SPLICING
    ].map { |x| [x, x] } .to_h

    class ScanError < StandardError; end

    # Constructor. Initialize a tokenizer for Skeem.
    # @param source [String] Skeem text to tokenize.
    def initialize(source)
      @scanner = StringScanner.new('')
      reinitialize(source)
    end


    # @param source [String] Skeem text to tokenize.
    def reinitialize(source)
      @scanner.string = source
      @lineno = 1
      @line_start = 0
    end

    # @return [Array<SkmToken>] | Returns a sequence of tokens
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
      elsif (lexeme = scanner.scan(/(?:\.)(?=\s)/)) # Single char occurring alone
        token = build_token('PERIOD', lexeme)
      elsif (lexeme = scanner.scan(/,@?/))
        token = build_token(@@lexeme2name[lexeme], lexeme)
      elsif (lexeme = scanner.scan(/#(?:(?:true)|(?:false)|(?:u8)|[\\\(tfeiodx]|(?:\d+[=#]))/))
        token = cardinal_token(lexeme)        
      elsif (lexeme = scanner.scan(/[+-]?[0-9]+(?=\s|[|()";]|$)/))
        token = build_token('INTEGER', lexeme) # Decimal radix
      elsif (lexeme = scanner.scan(/[+-]?[0-9]+(?:\.[0-9]+)?(?:(?:e|E)[+-]?[0-9]+)?/))
        # Order dependency: must be tested after INTEGER case
        token = build_token('REAL', lexeme)
      elsif (lexeme = scanner.scan(/"(?:\\"|[^"])*"/)) # Double quotes literal?
        token = build_token('STRING_LIT', lexeme)
      elsif (lexeme = scanner.scan(/[a-zA-Z!$%&*\/:<=>?@^_~][a-zA-Z0-9!$%&*+-.\/:<=>?@^_~+-]*/))
        keyw = @@keywords[lexeme.upcase]
        tok_type = keyw ? keyw : 'IDENTIFIER'
        token = build_token(tok_type, lexeme)
      elsif (lexeme = scanner.scan(/\|(?:[^|])*\|/)) # Vertical bar delimited
        token = build_token('IDENTIFIER', lexeme)
      elsif (lexeme = scanner.scan(/([\+\-])((?=\s|[|()";])|$)/))
        #  # R7RS peculiar identifiers case 1: isolated plus and minus as identifiers
        token = build_token('IDENTIFIER', lexeme)
      elsif (lexeme = scanner.scan(/[+-][a-zA-Z!$%&*\/:<=>?@^_~+-@][a-zA-Z0-9!$%&*+-.\/:<=>?@^_~+-]*/))
        # R7RS peculiar identifiers case 2
        token = build_token('IDENTIFIER', lexeme)
      elsif (lexeme = scanner.scan(/\.[a-zA-Z!$%&*\/:<=>?@^_~+-@.][a-zA-Z0-9!$%&*+-.\/:<=>?@^_~+-]*/))
        # R7RS peculiar identifiers case 4
        token = build_token('IDENTIFIER', lexeme)
      else # Unknown token
        erroneous = curr_ch.nil? ? '' : scanner.scan(/./)
        sequel = scanner.scan(/.{1,20}/)
        erroneous += sequel unless sequel.nil?
        raise ScanError, "Unknown token #{erroneous} on line #{lineno}"
      end

      return token
    end
    
=begin
#t #f These are the boolean constants (section 6.3), along
with the alternatives #true and #false.
#\ This introduces a character constant (section 6.6).
#( This introduces a vector constant (section 6.8). Vector
constants are terminated by ) .
#u8( This introduces a bytevector constant (section 6.9).
Bytevector constants are terminated by ) .
#e #i #b #o #d #x These are used in the notation for
numbers (section 6.2.5).
#<n>= #<n># These are used for labeling and referencing
other literal data (section 2.4).
        # token = build_token('BOOLEAN', lexeme)
=end    
    def cardinal_token(aLexeme)
      case aLexeme
      when /^#true|false|t|f$/
        token = build_token('BOOLEAN', aLexeme)
      when '#('
        token = build_token(@@lexeme2name[aLexeme], aLexeme)
      end
      
      return token
    end

    def build_token(aSymbolName, aLexeme, aFormat = :default)
      begin
        value = convert_to(aLexeme, aSymbolName, aFormat)
        col = scanner.pos - aLexeme.size - @line_start + 1
        pos = Rley::Lexical::Position.new(@lineno, col)
        token = Rley::Lexical::Token.new(value, aSymbolName, pos)
      rescue StandardError => exc
        puts "Failing with '#{aSymbolName}' and '#{aLexeme}'"
        raise exc
      end

      return token
    end

    def convert_to(aLexeme, aSymbolName, aFormat)
      case aSymbolName
      when 'BOOLEAN'
        value = to_boolean(aLexeme, aFormat)
      when 'INTEGER'
        value = to_integer(aLexeme, aFormat)
      when 'REAL'
        value = to_real(aLexeme, aFormat)
      when 'STRING_LIT'
        value = to_string(aLexeme, aFormat)
      when 'IDENTIFIER'
        value = to_identifier(aLexeme, aFormat)        
      else
        value = aLexeme
      end

      return value
    end

    def to_boolean(aLexeme, aFormat)
      result = (aLexeme =~ /^#t/) ? true : false
    end

    def to_integer(aLexeme, aFormat)
      case aFormat
      when :default, :base10
        value = aLexeme.to_i
      end

      return value
    end

    def to_real(aLexeme, aFormat)
      case aFormat
      when :default
        value = aLexeme.to_f
      end

      return value
    end
    
    def to_string(aLexeme, aFormat)
      case aFormat
      when :default
        value = aLexeme.gsub(/(^")|("$)/, '')
      end

      return value
    end  

    def to_identifier(aLexeme, aFormat)
      case aFormat
      when :default
        value = aLexeme
      end

      return value
    end     
    
    def skip_whitespaces
      pre_pos = scanner.pos

      loop do
        ws_found = false
        cmt_found = false
        found = scanner.skip(/[ \t\f]+/)
        ws_found = true if found
        found = scanner.skip(/(?:\r\n)|\r|\n/)
        if found
          ws_found = true
          next_line
        end
        next_ch = scanner.peek(1)
        if next_ch == ';'
          cmt_found = true
          scanner.skip(/;[^\r\n]*(?:(?:\r\n)|\r|\n)?/)
          next_line
        end
        break unless ws_found or cmt_found
      end

      curr_pos = scanner.pos
      return if curr_pos == pre_pos
    end
    
    def next_line
      @lineno += 1
      @line_start = scanner.pos
    end
  end # class
end # module
# End of file
