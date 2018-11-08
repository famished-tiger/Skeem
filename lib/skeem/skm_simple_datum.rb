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

    def symbol()
      token.terminal
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

  class SkmString < SkmSimpleDatum
    # Override
    def init_value(aValue)
      super(aValue.dup)
    end

    def string?
      true
    end
    
    def length
      value.length
    end
  end # class

  class SkmIdentifier < SkmSimpleDatum
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
end # module