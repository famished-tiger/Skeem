# Classes that implement nodes of Abstract Syntax Trees (AST) representing
# Skeem parse results.

require 'forwardable'

module Skeem
  # Abstract class. Generalization of any S-expr element.
  SExprElement = Struct.new(:position) do
    def initialize(aPosition)
      self.position = aPosition
    end

    def evaluate(_runtime)
      raise NotImplementedError
    end

    def done!()
      # Do nothing
    end

    # Abstract method.
    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor[ParseTreeVisitor] the visitor
    def accept(_visitor)
      raise NotImplementedError
    end
  end # struct

  # Abstract class. Root of class hierarchy needed for Interpreter
  # design pattern
  class SExprTerminal < SExprElement
    attr_reader :token
    attr_reader :value

    def initialize(aToken, aPosition)
      super(aPosition)
      @token = aToken
      init_value(aToken.lexeme)
    end

    def self.create(aValue)
      lightweight = self.allocate
      lightweight.init_value(aValue)
      return lightweight
    end

    # This method can be overriden
    def init_value(aValue)
      @value = aValue
    end

    def symbol()
      token.terminal
    end

    def evaluate(_runtime)
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
  end # class

  class SExprBoolean < SExprTerminal
  end # class

  class SExprNumber < SExprTerminal
  end # class

  class SExprReal < SExprTerminal
  end # class

  class SExprInteger < SExprReal
  end # class

  class SExprString < SExprTerminal
    # Override
    def init_value(aValue)
      super(aValue.dup)
    end
  end # class

  class SExprIdentifier < SExprTerminal
    # Override
    def init_value(aValue)
      super(aValue.dup)
    end
  end # class

  class SExprReserved < SExprIdentifier
  end # class


  class SExprList < SExprElement
    attr_accessor(:members)
    extend Forwardable

    def_delegator :@members, :first, :empty?

    def initialize(theMembers)
      super(nil)
      @members = theMembers.nil? ? [] : theMembers
    end

    def head()
      return members.first
    end
    
    def tail()
      SExprList.new(members.slice(1..-1))
    end

    # Factory method.
    # Construct an Enumerator that will return iteratively the result
    # of 'evaluate' method of each members of self.
    def to_eval_enum(aRuntime)
      elements = self.members

      new_enum = Enumerator.new do |result|
        context = aRuntime
        elements.each { |elem| result << elem.evaluate(context) }
      end

      new_enum
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param aVisitor[ParseTreeVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_nonterminal(self)
    end

    def done!()
      # Do nothing
    end

    alias children members
    alias subnodes members
  end # class

  class ProcedureCall < SExprElement
    attr_reader :operator
    attr_reader :operands

    def initialize(aPosition, anOperator, theOperands)
      super(aPosition)
      @operator = anOperator
      @operands = SExprList.new(theOperands)
    end

    def evaluate(aRuntime)
      proc_key = operator.evaluate(aRuntime)
      unless aRuntime.include?(proc_key.value)
        err = StandardError
        key = proc_key.kind_of?(SExprIdentifier) ? proc_key.value : proc_key
        err_msg = "Unknown function '#{key}'"
        raise err, err_msg
      end
      procedure = aRuntime.environment.bindings[proc_key.value]
      result = procedure.call(aRuntime, self)
    end

    alias children operands
  end # class
end # module
# End of file
