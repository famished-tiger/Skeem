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
  
  # Used to represent local binding constructs (let, let*, letrec, letrec*)
  class SkmBindingBlock < SkmUnaryExpression
    alias body child
    
    attr_reader :kind
    attr_reader :bindings
    
    def initialize(theKind, theBindings, aBody)
      @kind = theKind
      @bindings = theBindings
      super(nil, aBody)
    end
    
    def evaluate(aRuntime)
      if kind == :let
        aRuntime.push(SkmFrame.new(aRuntime.environment))
        locals = bindings.map do |bnd|
          SkmBinding.new(bnd.variable, bnd.value.evaluate(aRuntime))
        end
        locals.each do |bnd|
          aRuntime.add_binding(bnd.variable.evaluate(aRuntime), bnd.value)
        end
      end
      
      result = body[:sequence].evaluate(aRuntime)
      aRuntime.pop
      result.kind_of?(SkmPair) ? result.last : result
    end
    
  end # class
  
end # module