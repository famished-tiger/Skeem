# Classes that implement nodes of Abstract Syntax Trees (AST) representing
# Skeem parse results.

require 'forwardable'

module Skeem
  class SkmUndefined
    def value
      :UNDEFINED
    end
  end # class


  # Abstract class. Generalization of any S-expr element.
  SkmElement = Struct.new(:position) do
    def initialize(aPosition)
      self.position = aPosition
    end

    def evaluate(_runtime)
      raise NotImplementedError, "Missing implementation of #{self.class.name}"
    end

    def done!()
      # Do nothing
    end

    def number?
      false
    end

    def real?
      false
    end

    def integer?
      false
    end
    
    def boolean?
      false
    end

    def string?
      false
    end    

    def symbol?
      false
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
  class SkmTerminal < SkmElement
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

  class SkmBoolean < SkmTerminal
    def boolean?
      true
    end  
  end # class

  class SkmNumber < SkmTerminal
    def number?
      true
    end
  end # class

  class SkmReal < SkmNumber
    def real?
      true
    end
  end # class

  class SkmInteger < SkmReal
    def integer?
      true
    end
  end # class

  class SkmString < SkmTerminal
    # Override
    def init_value(aValue)
      super(aValue.dup)
    end
    
    def string?
      true
    end     
  end # class

  class SkmIdentifier < SkmTerminal
    # Override
    def init_value(aValue)
      super(aValue.dup)
    end
    
    def symbol?
      true
    end     
  end # class

  class SkmReserved < SkmIdentifier
  end # class


  class SkmList < SkmElement
    attr_accessor(:members)
    extend Forwardable

    def_delegators :@members, :first, :length, :empty?

    def initialize(theMembers)
      super(nil)
      @members = theMembers.nil? ? [] : theMembers
    end

    def head()
      return members.first
    end

    def tail()
      SkmList.new(members.slice(1..-1))
    end

    def evaluate(aRuntime)
      result = nil

      members.each do |elem|
        result = elem.evaluate(aRuntime)
      end

      result
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

  class SkmDefinition < SkmElement
    attr_reader :variable
    attr_reader :expression

    def initialize(aPosition, aVariable, theExpression)
      super(aPosition)
      @variable = aVariable
      @expression = theExpression
    end

    def evaluate(aRuntime)
      var_key = variable.evaluate(aRuntime)
      aRuntime.define(var_key, self)
      self
    end
  end # class
  
  class SkmVariableReference  < SkmElement
    attr_reader :variable
    
    def initialize(aPosition, aVariable)
      super(aPosition)
      @variable = aVariable
    end

    def evaluate(aRuntime)
      var_key = variable.evaluate(aRuntime)
      unless aRuntime.include?(var_key.value)
        err = StandardError
        key = var_key.kind_of?(SkmIdentifier) ? var_key.value : var_key
        err_msg = "Unknown variable '#{key}'"
        raise err, err_msg
      end
      definition = aRuntime.environment.bindings[var_key.value]
      result = definition.expression.evaluate(aRuntime)
    end

    # Confusing!
    # Value, here, means the value of the identifier (the variable's name).
    def value()
      variable.value
    end
  end

  class ProcedureCall < SkmElement
    attr_reader :operator
    attr_reader :operands

    def initialize(aPosition, anOperator, theOperands)
      super(aPosition)
      if anOperator.kind_of?(SkmVariableReference)
        # Kinky: variable names are procedure names, not variable reference
        @operator = SkmIdentifier.create(anOperator.value)
      else
        @operator = anOperator
      end
      @operands = SkmList.new(theOperands)
    end

    def evaluate(aRuntime)
      var_key = operator.evaluate(aRuntime)
      unless aRuntime.include?(var_key.value)
        err = StandardError
        key = var_key.kind_of?(SkmIdentifier) ? var_key.value : var_key
        err_msg = "Unknown procedure '#{key}'"
        raise err, err_msg
      end
      procedure = aRuntime.environment.bindings[var_key.value]
      result = procedure.call(aRuntime, self)
    end

    alias children operands
  end # class
  
  class SkmCondition < SkmElement
    attr_reader :test
    attr_reader :consequent
    attr_reader :alternate

    def initialize(aPosition, aTest, aConsequent, anAlternate)
      super(aPosition)
      @test = aTest
      @consequent = aConsequent
      @alternate = anAlternate
    end

    def evaluate(aRuntime)
      test_result = test.evaluate(aRuntime)
      condition_result = nil
      if test_result.boolean? && test_result.value == false
        # Only #f is considered as false, everything else is true
        condition_result = alternate ? alternate.evaluate(aRuntime) : SkmUndefined.new
      else
        condition_result = consequent.evaluate(aRuntime)
      end
    end
  end # class
end # module
# End of file
