module Skeem
  # Abstract class. Generalization of any S-expr element.
  SkmElement = Struct.new(:position) do
    def initialize(aPosition)
      self.position = aPosition
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

    def vector?
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

    def done!()
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
      raise NotImplementedError
    end
  end # struct
end # module