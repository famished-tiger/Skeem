module Skeem
  # Abstract class. Generalization of any S-expr element.
  SkmElement = Struct.new(:position) do
    def initialize(aPosition)
      self.position = aPosition
    end
    
    def callable?
      false
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

    def list?
      false
    end

    def null?
      false
    end

    def pair?
      false
    end
    
    def procedure?
      false
    end

    def vector?
      false
    end

    def eqv?(other)
      equal?(other)
    end

    def skm_equal?(_other)
      msg = "Missing implementation of method #{self.class.name}##{__method__}"
      raise NotImplementedError, msg
    end

    # @return [TrueClass, FalseClass] true if quoted element is identical to itself
    def verbatim?
      false
    end

    def evaluate(_runtime)
      raise NotImplementedError, "Missing implementation of #{self.class.name}"
    end

    def quasiquote(_runtime)
      raise NotImplementedError, "Missing implementation of #{self.class.name}"
    end

    # Abstract method.
    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor [SkmElementVisitor] the visitor
    def accept(_visitor)
      raise NotImplementedError
    end

    def done!
      # Do nothing
    end

    def quoted!
      # Do nothing
    end

    def unquoted!
      # Do nothing
    end

    # Notification that this procedure is bound to a variable
    # @param [Skemm::SkmFrame]
    def bound!(_frame)
      # Do nothing
    end

   def inspect
      result = inspect_prefix
      result << inspect_specific
      result << inspect_suffix

      result
    end

    protected

    def inspect_prefix
      "<#{self.class.name}: "
    end

    def inspect_suffix
      '>'
    end

    def inspect_specific
      raise NotImplementedError, "Missing #{self.class.to_s + '#' + 'inspect_specific'}"
    end
  end # struct
end # module