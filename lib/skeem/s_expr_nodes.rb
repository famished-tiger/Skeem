# Classes that implement nodes of Abstract Syntax Trees (AST) representing
# Skeem parse results.

require_relative 'skm_simple_datum'
require_relative 'skm_compound_datum'
require_relative 'skm_unary_expression'

module Skeem
  class SkmUndefined
    def value
      :UNDEFINED
    end

    def ==(other)
      return true if other.kind_of?(SkmUndefined)

      result = case other
        when Symbol
          self.value == other
        when String
          self.value.to_s == other
        else
          raise StandardError, other.inspect
      end
    end
  end # class

  class SkmMultiExpression < SkmExpression
    # Part of the 'visitee' role in Visitor design pattern.
    # @param _visitor [SkmElementVisitor] the visitor
    def accept(aVisitor)
      aVisitor.visit_multi_expression(self)
    end

    # @return [Array] the names of attributes referencing child SkmElement.
    def associations
      raise NotImplementedError
    end
  end

  class SkmDefinition < SkmMultiExpression
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
            entry = aRuntime.fetch(other_key)
            result = expression.evaluate(aRuntime)
            if entry.kind_of?(Primitive::PrimitiveProcedure)
              @expression = entry
            elsif entry.kind_of?(SkmDefinition)
              if entry.expression.kind_of?(SkmLambda)
                @expression = entry.expression
              end
            end
          else
            # INFINITE LOOP DANGER: definition of 'x' has a reference to 'x'!
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

    def quasiquote(aRuntime)
      quasi_var = variable.quasiquote(aRuntime)
      quasi_expression = variable.quasiquote(aRuntime)

      if quasi_var.equal?(variable) && quasi_expression.equal?(expression)
        self
      else
        self.class.new(position, quasi_var, quasi_expression)
      end
    end

    # call method should only invoked when the expression is a SkmLambda
    def call(aRuntime, aProcedureCall)
      expr = expression
      expr = expr.evaluate(aRuntime) if expr.kind_of?(SkmVariableReference)
      unless [SkmLambda, Primitive::PrimitiveProcedure].include?(expr.class)
        err_msg = "Expected a SkmLambda instead of #{expr.class}"
        raise StandardError, err_msg
      end
      # $stderr.puts "SkmDefinition#call #{aProcedureCall.inspect}"
      expr.call(aRuntime, aProcedureCall)
    end

    def inspect
      result = inspect_prefix
      result << variable.inspect
      result << ', '
      result << expression.inspect
      result << inspect_suffix
      result
    end

    def associations
      [:variable, :expression]
    end
  end # class

  class ProcedureCall < SkmMultiExpression
    attr_reader :operator
    attr_reader :operands
    attr_accessor :call_site
    attr_accessor :operands_consumed

    def initialize(aPosition, anOperator, theOperands)
      super(aPosition)
      if anOperator.kind_of?(SkmVariableReference)
        # Kinky: variable names are procedure names, not variable reference
        @operator = SkmIdentifier.create(anOperator.value)
      else
        @operator = anOperator
      end
      @operands = SkmList.new(theOperands)
      @operands_consumed = false
    end

    def evaluate(aRuntime)
      aRuntime.push_call(self)
      if operator.kind_of?(SkmLambda)
        procedure = operator
      else
        var_key = operator.evaluate(aRuntime)
        if operator.kind_of?(ProcedureCall) && operands_consumed
          return var_key
        end
        begin
          aRuntime.include?(var_key.value)
        rescue NoMethodError => exc
          # $stderr.puts "VVVVVVVVVVVVVVV"
          # $stderr.puts 'var_key: ' + var_key.inspect
          # $stderr.puts 'operator: ' + operator.inspect
          # $stderr.puts 'operands: ' + operands.inspect
          # $stderr.puts 'operands_consumed: ' + operands_consumed.inspect
          # $stderr.puts "^^^^^^^^^^^^^^^"
          raise exc
        end
        unless aRuntime.include?(var_key.value)
          err = StandardError
          key = var_key.kind_of?(SkmIdentifier) ? var_key.value : var_key
          err_msg = "Unknown procedure '#{key}'"
          raise err, err_msg
        end
        procedure = aRuntime.environment.fetch(var_key.value)
      end
      unless var_key.nil?
        # $stderr.puts "## In ProcCall #{var_key.value} #############"
        # $stderr.puts 'operator: ' + operator.inspect
        # $stderr.puts 'operands: ' + operands.inspect
        # $stderr.puts "## CALL(#{var_key.value}) ###################"
        # $stderr.puts 'callee: ' + procedure.inspect
      end
      result = procedure.call(aRuntime, self)
      operands_consumed = true
      aRuntime.pop_call
      # $stderr.puts "## RETURN #{result.inspect} from #{var_key.value}"
      result
    end

    def quasiquote(aRuntime)
      quasi_operator = operator.quasiquote(aRuntime)
      quasi_operands = operands.map { |oper | oper.quasiquote(aRuntime) }

       self.class.new(position, quasi_operator, quasi_operands)
    end

    def inspect
      result = inspect_prefix + operator.inspect + ', '
      result << '@operands ' + operands.inspect + inspect_suffix
      result
    end

    def associations
      [:operator, :operands]
    end

    alias children operands
  end # class

  class SkmCondition < SkmMultiExpression
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

    def quasiquote(aRuntime)
      quasi_test = test.quasiquote(aRuntime)
      quasi_consequent = consequent.quasiquote(aRuntime)
      quasi_alternate = alternate.quasiquote(aRuntime)

       self.class.new(position, quasi_test, quasi_consequent, quasi_alternate)
    end

    def inspect
      result = inspect_prefix + '@test ' + test.inspect + ', '
      result << '@consequent ' + consequent.inspect + ', '
      result << '@alternate ' + alternate.inspect + inspect_suffix
      result
    end

    def associations
      [:test, :consequent, :alternate]
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

  class SkmLambda < SkmMultiExpression
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
      # formals.evaluate(aRuntime)
      self
    end
=begin
  TODO
    def quasiquote(aRuntime)
      quasi_test = test.quasiquote(aRuntime)
      quasi_consequent = consequent.quasiquote(aRuntime)
      quasi_alternate = alternate.quasiquote(aRuntime)

       self.class.new(position, quasi_test, quasi_consequent, quasi_alternate)
    end
=end
    def call(aRuntime, aProcedureCall)
      aRuntime.nest
      bind_locals(aRuntime, aProcedureCall)
      # $stderr.puts 'LOCALS vvvvvvvvvvv'
      # $stderr.puts aRuntime.environment.inspect
      # $stderr.puts 'LOCALS ^^^^^^^^^^^'
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

    alias eqv? equal?

    def inspect
      result = inspect_prefix + '@formals ' + formals.inspect + ', '
      result << '@definitions ' + definitions.inspect + ', '
      result << '@sequence ' + sequence.inspect + inspect_suffix
      result
    end

    def associations
      [:formals, :definitions, :sequence]
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
      aProcedureCall.operands_consumed = true
    end

    def evaluate_defs(aRuntime)
      definitions.each { |a_def| a_def.evaluate(runtime) }
    end

    def evaluate_sequence(aRuntime)
      result = nil
      if sequence
        sequence.each do |cmd|
          if cmd.kind_of?(SkmLambda)
            caller_index = -2
            loop do
              raise StandardError, "Missing argument" unless aRuntime.caller(caller_index)
              unless aRuntime.caller(caller_index).operands_consumed
                aRuntime.caller(caller_index).operands_consumed = true
                result = cmd.call(aRuntime, aRuntime.caller(caller_index))
                break
              end
              caller_index -= 1
            end
          else
            result = cmd.evaluate(aRuntime)
          end
        end
      end

      result
    end

    # Purpose: bind each formal from lambda to an actual value from the call
    def bind_required_locals(aRuntime, aProcedureCall)
      max_index = required_arity - 1
      actuals =  aProcedureCall.operands.members
      formal_names = formals.formals.map(&:value)

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
        # $stderr.puts "Procedure call #{aProcedureCall.operator.inspect}"
        # $stderr.puts "LOCAL #{arg_name.value} #{arg.inspect}"
        if arg.kind_of?(SkmVariableReference) && !formal_names.include?(arg.value)
          aRuntime.define(arg_name, a_def)
        else
          a_def.evaluate(aRuntime)
        end
        break if index >= max_index
      end
    end

    def msg_arity_mismatch(aProcCall)
      # *** ERROR: wrong number of arguments for #<closure morph> (required 2, got 1)
      msg1 = "Wrong number of arguments for procedure #{aProcCall.operator} "
      count_actuals = aProcCall.operands.members.size
      msg2 = "(required #{required_arity}, got #{count_actuals})"
      msg1 + msg2
    end
  end # class
end # module
# End of file
