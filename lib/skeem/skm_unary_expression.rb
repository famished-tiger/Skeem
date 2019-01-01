require_relative 'skm_expression'

module Skeem
  class SkmUnaryExpression < SkmExpression
    attr_reader :child

    def initialize(aPosition, aChild)
      super(aPosition)
      @child = aChild
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor [SkmElementVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_unary_expression(self)
    end

    protected

    def inspect_specific
      child.inspect
    end
  end # class

  class SkmQuotation < SkmUnaryExpression
    alias datum child

    def initialize(aDatum)
      super(nil, aDatum)
    end

    def evaluate(aRuntime)
      datum
    end

    def quasiquote(aRuntime)
      quasi_child = child.quasiquote(aRuntime)
      if quasi_child.equal?(child)
        self
      else
        self.class.new(quasi_child)
      end
    end

    protected

    def inspect_specific
      datum.inspect
    end

  end # class

  class SkmQuasiquotation < SkmQuotation
    alias template child

    def evaluate(aRuntime)
      quasiquote(aRuntime)
    end

    def quasiquote(aRuntime)
      child.quasiquote(aRuntime)
    end

  end # class

  class SkmUnquotation < SkmUnaryExpression
    alias template child

    def initialize(aTemplate)
      super(nil, aTemplate)
      child.unquoted!
    end

    def evaluate(aRuntime)
      template.evaluate(aRuntime)
    end

    def quasiquote(aRuntime)
      result = evaluate(aRuntime)
      result
    end

    protected

    def inspect_specific
      template.inspect
    end
  end # class

  class SkmVariableReference  < SkmUnaryExpression
    alias variable child

    def eqv?(other)
      child == other.child
    end

    def evaluate(aRuntime)
      var_key = variable.evaluate(aRuntime)
      # $stderr.puts "Variable #{variable.inspect}"
      aRuntime.evaluate(var_key)
    end

    def quasiquote(aRuntime)
      self
    end

    # Confusing!
    # Value, here, means the value of the identifier (the variable's name).
    def value()
      variable.value
    end
  end # class
end # module