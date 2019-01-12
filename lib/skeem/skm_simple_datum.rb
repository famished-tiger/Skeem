require_relative 'skm_element'

module Skeem
  # Abstract class. Root of class hierarchy needed for Interpreter
  # design pattern
  class SkmSimpleDatum < SkmElement
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
      return true if self.equal?(other)

      result = if other.kind_of?(SkmSimpleDatum)
          self.value == other.value
        else
          self.value == other
        end

      result
    end

    alias eqv? ==
    alias skm_equal? eqv?

    def verbatim?
      true
    end

    def done!()
      # Do nothing
    end

    # Evaluate the Skeem expression represented by this object.
    # Reminder: terminals evaluate to themselves.
    # @param _runtime [Skeem::Runtime]
    def evaluate(_runtime)
      return self
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

    def eqv?(other)
      return true if self.equal?(other)

      result = if other.kind_of?(SkmNumber)
        if self.exact? != other.exact?
          false
        else
          self.value == other.value
        end
      else
        self.value == other
      end

      result
    end
  end # class

  class SkmReal < SkmNumber
    def real?
      true
    end

    def exact?
      false
    end
  end # class

  class SkmInteger < SkmReal
    def integer?
      true
    end

    def exact?
      true
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
      not is_var_name
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