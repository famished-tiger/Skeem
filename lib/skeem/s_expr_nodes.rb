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
    
    def list?
      false
    end
    
    def null?
      false
    end
    
    def vector?
      false
    end

    # Abstract method.
    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor[ParseTreeVisitor] the visitor
    def accept(_visitor)
      raise NotImplementedError
    end

   def inspect
      raise NotImplementedError, "Missing #{self.class}#inspect method."
    end

    protected

    def inspect_prefix
      "<#{self.class.name}: "
    end

    def inspect_suffix
      '>'
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

    def symbol()
      token.terminal
    end

    def evaluate(_runtime)
      return self
    end

    def inspect()
      inspect_prefix + value.to_s + inspect_suffix
    end

    def done!()
      # Do nothing
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param aVisitor[ParseTreeVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_terminal(self)
    end

    # This method can be overriden
    def init_value(aValue)
      @value = aValue
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

    def_delegators :@members, :each, :first, :last, :length, :empty?, :size

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
    
    def list?
      true
    end
    
    def null?
      empty?
    end

    def evaluate(aRuntime)
      list_evaluated = members.map { |elem| elem.evaluate(aRuntime) }
      SkmList.new(list_evaluated)
    end

    # Factory method.
    # Construct an Enumerator that will return iteratively the result
    # of 'evaluate' method of each members of self.
    def to_eval_enum(aRuntime)
=begin
      elements = self.members

      new_enum = Enumerator.new do |result|
        context = aRuntime
        elements.each { |elem| result << elem.evaluate(context) }
      end

      new_enum
=end
      members.map { |elem| elem.evaluate(aRuntime) }
    end

    # Part of the 'visitee' role in Visitor design pattern.
    # @param aVisitor[ParseTreeVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_nonterminal(self)
    end

    def done!()
      # Do nothing
    end

    def inspect()
      result = inspect_prefix
      members.each { |elem| result << elem.inspect + ', ' }
      result.sub!(/, $/, '')
      result << inspect_suffix
      result
    end

    alias children members
    alias subnodes members
    alias to_a members  
    alias rest tail
  end # class
  
  class SkmVector < SkmElement
    attr_accessor(:elements)
    extend Forwardable

    def_delegators :@elements, :each, :length, :empty?, :size    
    
    def initialize(theElements)
      super(nil)
      @elements = theElements.nil? ? [] : theElements
    end
    
    def vector?
      true
    end

    def evaluate(aRuntime)
      elements_evaluated = elements.map { |elem| elem.evaluate(aRuntime) }
      SkmVector.new(elements_evaluated)
    end

    def inspect()
      result = inspect_prefix
      elements.each { |elem| result << elem.inspect + ', ' }
      result.sub!(/, $/, '')
      result << inspect_suffix
      result
    end   
  
  end # class
  
  
  class SkmQuotation < SkmElement
    attr_accessor(:datum)  
    
    def initialize(aDatum)
      super(nil)
      @datum = aDatum
    end

    def evaluate(aRuntime)
      datum
    end
    
    def inspect
      result = inspect_prefix
      result << datum.inspect
      result << inspect_suffix
      result      
    end
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
      case expression
        when SkmLambda
          result = expression.evaluate(aRuntime)

        when SkmVariableReference
          other_key = expression.variable.evaluate(aRuntime)
          if var_key.value != other_key.value
            result = expression.evaluate(aRuntime)
           else
            # INFINITE LOOP DANGER: definition of 'x' is a reference to 'x'!
            # Way out: the lookup for the reference should start from outer
            # environment.
            env = aRuntime.pop
            @expression = expression.evaluate(aRuntime)
            aRuntime.push(env)
            result = expression
          end
        else
          result = self
      end

      result
    end

    # call method should only invoked when the expression is a SkmLambda
    def call(aRuntime, aProcedureCall)
      unless expression.kind_of?(SkmLambda)
        err_msg = "Expected a SkmLambda instead of #{expression.class}"
        raise StandardError, err_msg
      end
      expression.call(aRuntime, aProcedureCall)
    end

    def inspect
      result = inspect_prefix
      result << variable.inspect
      result << ', '
      result << expression.inspect
      result << inspect_suffix
      result
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
        err_msg = "Unbound variable: '#{key}'"
        raise err, err_msg
      end
      definition = aRuntime.environment.fetch(var_key.value)
      result = definition.expression.evaluate(aRuntime)
    end

    # Confusing!
    # Value, here, means the value of the identifier (the variable's name).
    def value()
      variable.value
    end

    def inspect
      result = inspect_prefix + variable.inspect + inspect_suffix
      result
    end
  end # class

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
      if operator.kind_of?(SkmLambda)
        procedure = operator
      else
        var_key = operator.evaluate(aRuntime)
        unless aRuntime.include?(var_key.value)
          err = StandardError
          key = var_key.kind_of?(SkmIdentifier) ? var_key.value : var_key
          err_msg = "Unknown procedure '#{key}'"
          raise err, err_msg
        end
        procedure = aRuntime.environment.fetch(var_key.value)
        # $stderr.puts "## CALL(#{var_key.value}) ###################"
        # $stderr.puts operands.inspect
      end
      result = procedure.call(aRuntime, self)
      # $stderr.puts "## RETURN #{result.inspect}"
      result
    end

    def inspect
      result = inspect_prefix + operator.inspect + ', '
      result << '@operands ' + operands.inspect + inspect_suffix
      result
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

    def inspect
      result = inspect_prefix + '@test ' + test.inspect + ', '
      result << '@consequent ' + consequent.inspect + ', '
      result << '@alternate ' + alternate.inspect + inspect_suffix
      result
    end
  end # class

  SkmArity = Struct.new(:low, :high) do
    def nullary?
      low.zero? && high == 0
    end

    def variadic?
      high == '*'
    end

    def ==(other)
      return true if self.object_id == other.object_id
      result = false

      case other
        when SkmArity
          result = true if (low == other.low) && (high == other.high)
        when Array
          result = true if (low == other.first) && (high == other.last)
        when Integer
          result = true if (low == other) && (high == other)
      end

      result
    end
  end

  class SkmFormals
    attr_reader :formals
    attr_reader :arity

    # @param arityKind [Symbol] One of the following: :fixed, :variadic
    def initialize(theFormals, arityKind)
      @formals = theFormals
      arity_set(arityKind)
    end

    def evaluate(aRuntime)
      formals.map! { |param| param.evaluate(aRuntime) }
    end

    def nullary?
      arity.nullary?
    end

    def variadic?
      arity.variadic?
    end

    def required_arity
      (arity.high == '*') ? arity.low : arity.high
    end

    private

    def arity_set(arityKind)
      fixed_arity = formals.size

      if arityKind == :fixed
        @arity = SkmArity.new(fixed_arity, fixed_arity)
      else # :variadic
        if formals.empty?
          raise StandardError, 'Internal error: inconsistent arity'
        else
          @arity = SkmArity.new(fixed_arity - 1, '*')
        end
      end
    end
  end # class

  class SkmLambda < SkmElement
    # @!attribute [r] formals
    # @return [Array<SkmIdentifier>] the argument names
    attr_reader :formals
    attr_reader :definitions
    attr_reader :sequence

    def initialize(aPosition, theFormals, aBody)
      super(aPosition)
      @formals = theFormals
      @definitions = aBody[:defs]
      @sequence = aBody[:sequence]
    end

    def evaluate(aRuntime)
      formals.evaluate(aRuntime)
    end

    def call(aRuntime, aProcedureCall)
      aRuntime.nest
      bind_locals(aRuntime, aProcedureCall)
      # TODO remove next line
      # $stderr.puts aRuntime.environment.inspect
      result = evaluate_defs(aRuntime)
      result = evaluate_sequence(aRuntime)
      aRuntime.unnest

      result
    end

    def arity
      formals.arity
    end

    def required_arity
      formals.required_arity
    end

    def inspect
      result = inspect_prefix + '@formals ' + formals.inspect + ', '
      result << '@definitions ' + definitions.inspect + ', '
      result << '@sequence ' + sequence.inspect + inspect_suffix
      result
    end

    private

    def bind_locals(aRuntime, aProcedureCall)
      actuals =  aProcedureCall.operands.members
      count_actuals = actuals.size
      
      if (count_actuals < required_arity) ||
        ((count_actuals > required_arity) && !formals.variadic?)
        raise StandardError, msg_arity_mismatch(aProcedureCall)
      end
      return if count_actuals.zero? && !formals.variadic?
      bind_required_locals(aRuntime, aProcedureCall)
      if formals.variadic?
        variadic_part_raw = actuals.drop(required_arity)
        variadic_part = variadic_part_raw.map do |actual|
          if actual.kind_of?(ProcedureCall)
            actual.evaluate(aRuntime)           
          else
            actual
          end
        end
        variadic_arg_name = formals.formals.last
        args_coll = SkmList.new(variadic_part)
        a_def = SkmDefinition.new(position, variadic_arg_name, args_coll)
        a_def.evaluate(aRuntime)        
      end
    end

    def evaluate_defs(aRuntime)
      definitions.each { |a_def| a_def.evaluate(runtime) }
    end

    def evaluate_sequence(aRuntime)
      result = nil
      if sequence
        sequence.each { |cmd| result = cmd.evaluate(aRuntime) }
      end

      result
    end

    def bind_required_locals(aRuntime, aProcedureCall)
      max_index = required_arity - 1
      actuals =  aProcedureCall.operands.members

      formals.formals.each_with_index do |arg_name, index|
        arg = actuals[index]
        if arg.nil?
          if actuals.empty? && formals.variadic?
            arg = SkmList.new([])
          else
            raise StandardError, "Unbound variable: '#{arg_name.value}'"
          end
        end

        # IMPORTANT: execute procedure call in argument list now
        arg = arg.evaluate(aRuntime) if arg.kind_of?(ProcedureCall)
        a_def = SkmDefinition.new(position, arg_name, arg)
        a_def.evaluate(aRuntime)
        # $stderr.puts "LOCAL #{a_def.inspect}"
        break if index >= max_index
      end
    end
    
    def msg_arity_mismatch(aProcedureCall)
      # *** ERROR: wrong number of arguments for #<closure morph> (required 2, got 1)
      msg1 = "Wrong number of arguments for procedure #{operator} "
      count_actuals = aProcedureCall.operands.members.size
      msg2 = "(required #{required_arity}, got #{count_actuals})"
      msg1 + msg2
    end
  end # class
end # module
# End of file
