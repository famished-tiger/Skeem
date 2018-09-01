# Classes that implement nodes of Abstract Syntax Trees (AST) representing
# Skeem parse results.

module Skeem
  # Abstract class. Root of class hierarchy needed for Interpreter
  # design pattern
  SExprTerminalNode = Struct.new(:token, :value, :position) do
    def initialize(aToken, aPosition)
      self.token = aToken
      self.position = aPosition
      init_value(aToken.lexeme)
    end

    # This method can be overriden
    def init_value(aValue)
      self.value = aValue
    end

    def symbol()
      token.terminal
    end

    def interpret()
      return self
    end
    
    def done!()
      # Do nothing
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param aVisitor[ParseTreeVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_terminal(self)
    end
  end

  class SExprBooleanNode < SExprTerminalNode
  end # class
  
  class SExprNumberNode < SExprTerminalNode
  end # class  
  
  class SExprRealNode < SExprNumberNode
  end # class
  
  class SExprIntegerNode < SExprRealNode
  end # class
  
  class SExprStringNode < SExprTerminalNode
    # Override
    def init_value(aValue)
      self.value = aValue.dup
    end  
  end # class
  
  class SExprIdentifierNode < SExprTerminalNode
    # Override
    def init_value(aValue)
      self.value = aValue.dup
    end  
  end # class
  
=begin
  class SExprCompositeNode
    attr_accessor(:children)
    attr_accessor(:symbol)
    attr_accessor(:position)

    def initialize(aSymbol, aPosition)
      @symbol = aSymbol
      @children = []
      @position = aPosition
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param aVisitor[ParseTreeVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_nonterminal(self)
    end
    
    def done!()
      # Do nothing
    end

    alias subnodes children
  end # class

  class SExprUnaryOpNode < SExprCompositeNode
    def initialize(aSymbol, aPosition)
      super(aSymbol, aPosition)
    end

    alias members children
  end # class
=end
end # module
# End of file
