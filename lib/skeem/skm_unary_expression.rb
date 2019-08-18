# frozen_string_literal: true

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

    def evaluate(_runtime)
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

  class SkmVariableReference < SkmUnaryExpression
    alias variable child

    def eqv?(other)
      child == other.child
    end

    def evaluate(aRuntime)
      var_key = variable.evaluate(aRuntime)
      # $stderr.puts "Variable #{variable.inspect}"
      aRuntime.evaluate(var_key)
    end

    def quasiquote(_runtime)
      self
    end

    # Confusing!
    # Value, here, means the value of the identifier (the variable's name).
    def value
      variable.value
    end
  end # class

  # Used to represent local binding constructs (let, let\*, letrec, letrec\*)
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
      aRuntime.push(SkmFrame.new(aRuntime.environment))
      if kind == :let
        locals = bindings.map do |bnd|
          SkmBinding.new(bnd.variable, bnd.value.evaluate(aRuntime))
        end
        locals.each do |bnd|
          aRuntime.add_binding(bnd.variable.evaluate(aRuntime), bnd.value)
        end
      elsif kind == :let_star
        bindings.each do |bnd|
          val = bnd.value.evaluate(aRuntime)
          aRuntime.add_binding(bnd.variable.evaluate(aRuntime), val)
        end
      end

      unless body[:defs].empty?
        body[:defs].each do |dfn|
          dfn.evaluate(aRuntime)
        end
      end

      # $stderr.puts "Environment SkmBindingBlock#evaluate:" + aRuntime.environment.inspect
      raw_result = body[:sequence].evaluate(aRuntime)
      result = raw_result.kind_of?(SkmPair) ? raw_result.last : raw_result
      result = result.doppelganger(aRuntime) if result.kind_of?(SkmLambda)

      aRuntime.pop
      # $stderr.puts "Result SkmBindingBlock#evaluate: " + result.inspect
      result
    end
  end # class

  # Sequencing construct
  class SkmSequencingBlock < SkmUnaryExpression
    alias sequence child # Can be a body

    def initialize(aSequence)
      super(nil, aSequence)
    end

    def evaluate(aRuntime)
      result = nil
      return result if sequence.nil?

      case sequence
        when SkmPair
          result = eval_pair(aRuntime)
        when Hash
          result = eval_body(aRuntime)
        else
          result = sequence.evaluate(aRuntime)
      end

      result
    end

    private

    def eval_pair(aRuntime)
      result = nil
      sequence.to_a.each do |cmd|
        begin
          if cmd.kind_of?(SkmLambda)
            result = cmd.dup_cond(aRuntime)
          else
            result = cmd.evaluate(aRuntime)
          end
        rescue NoMethodError => e
          $stderr.puts inspect
          $stderr.puts sequence.inspect
          $stderr.puts cmd.inspect
          raise e
        end
      end

      result
    end

    def eval_body(aRuntime)
      result = nil
      aRuntime.push(SkmFrame.new(aRuntime.environment))

      unless sequence[:defs].empty?
        sequence[:defs].each do |dfn|
          dfn.evaluate(aRuntime)
        end
      end

      if sequence[:sequence].kind_of?(SkmPair)
        sequence[:sequence].to_a.each do |cmd|
          begin
            if cmd.kind_of?(SkmLambda)
              result = cmd.dup_cond(aRuntime)
            else
              result = cmd.evaluate(aRuntime)
            end
          rescue NoMethodError => e
            $stderr.puts inspect
            $stderr.puts sequence[:sequence].inspect
            $stderr.puts cmd.inspect
            raise e
          end
        end
      else
        result = sequence.evaluate(aRuntime)
      end

      aRuntime.pop

      result
    end
  end # class
end # module
