# frozen_string_literal: true

require_relative 'skm_element'

module Skeem
  # Abstract class. Root of class hierarchy needed for Interpreter
  # design pattern
  class SkmSimpleDatum < SkmElement
    # @return [Rley::Syntax::Token] token object corresponding to Skeem element
    attr_reader :token

    # @return [Object]
    attr_reader :value

    def initialize(aToken, aPosition)
      super(aPosition)
      @token = aToken
      init_value(aToken.lexeme)
    end

    def self.create(aValue)
      lightweight = allocate
      lightweight.init_value(aValue)
      lightweight
    end

    def symbol
      token.terminal
    end

    def position
      token.position
    end

    # Equality operator.
    # Returns true when: self and 'other' are identical, or
    # when they have same value
    # @param other [SkmSimpleDatum, Object] object to compare with.
    # @return [TrueClass, FalseClass]
    def ==(other)
      return true if equal?(other)

      if other.kind_of?(SkmSimpleDatum)
        value == other.value
      else
        value == other
      end
    end

    alias eqv? ==
    alias skm_equal? eqv?

    def verbatim?
      true
    end

    def done!
      # Do nothing
    end

    # Evaluate the Skeem expression represented by this object.
    # Reminder: terminals evaluate to themselves.
    # @param _runtime [Skeem::Runtime]
    def evaluate(_runtime)
      self
    end

    # Return this object un-evaluated.
    # Reminder: As terminals are atomic, there is no need to launch a visitor.
    # @param _runtime [Skeem::Runtime]
    def quasiquote(runtime)
      evaluate(runtime)
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor [SkmElementVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_simple_datum(self)
    end

    # This method can be overriden
    def init_value(aValue)
      @value = aValue
    end

    protected

    def inspect_specific
      value.to_s
    end
  end # class

  class SkmBoolean < SkmSimpleDatum
    def boolean?
      true
    end
  end # class

  class SkmNumber < SkmSimpleDatum
    def number?
      true
    end

    def complex?
      false
    end

    # rubocop: disable Style/NegatedIfElseCondition

    def eqv?(other)
      return true if equal?(other)

      if other.kind_of?(SkmNumber)
        if exact? != other.exact?
          false
        else
          value == other.value
        end
      else
        value == other
      end
    end
    # rubocop: enable Style/NegatedIfElseCondition
  end # class

  class SkmReal < SkmNumber
    def real?
      true
    end

    def complex?
      true
    end

    def exact?
      false
    end
  end # class

  class SkmRational < SkmReal
    def rational?
      true
    end

    def exact?
      true
    end
  end # class

  class SkmInteger < SkmRational
    def integer?
      true
    end
  end # class

  class SkmChar < SkmSimpleDatum
    def char?
      true
    end

    def self.create_from_int(anInteger)
      int_value = anInteger.kind_of?(SkmInteger) ? anInteger.value : anInteger
      char_value = int_value < 0xff ? int_value.chr : [int_value].pack('U')
      create(char_value)
    end
  end # class

  class SkmString < SkmSimpleDatum
    # Override
    def init_value(aValue)
      super(aValue.dup)
    end

    def string?
      true
    end

    alias eqv? equal?

    def length
      value.length
    end
  end # class

  class SkmIdentifier < SkmSimpleDatum
    # Tells whether the identifier is used as a variable name.
    # @return [TrueClass, FalseClass]
    attr_accessor :is_var_name

    def initialize(aToken, aRank, isVarName = false)
      super(aToken, aRank)
      @is_var_name = isVarName
    end

    # Override
    def init_value(aValue)
      super(aValue.dup)
    end

    def symbol?
      true
    end

    def verbatim?
      !is_var_name
    end

    def quoted!
      self.is_var_name = false
    end

    def unquoted!
      self.is_var_name = true
    end
  end # class

  class SkmReserved < SkmIdentifier
  end # class
end # module
