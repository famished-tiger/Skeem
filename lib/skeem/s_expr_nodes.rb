# Classes that implement nodes of Abstract Syntax Trees (AST) representing
# Skeem parse results.
require 'singleton'

require_relative 'datum_dsl'
require_relative 'skm_unary_expression'

module Skeem
  class SkmUndefined
    include Singleton

    def value
      self
    end

    def ==(other)
      equal?(other)
    end

    private

    def initialize
      self.freeze
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

  class ProcedureCall < SkmMultiExpression
    attr_reader :operator
    attr_reader :operands

    attr_accessor :call_site

    # @return [FalseClass, TrueClass] True if all arguments are used by callee.
    attr_accessor :operands_consumed

    def initialize(aPosition, anOperator, theOperands)
      super(aPosition)
      if anOperator.kind_of?(SkmVariableReference)
        # Kinky: variable names are procedure names, not variable reference
        @operator = SkmIdentifier.create(anOperator.value)
      else
        @operator = anOperator
      end
      if theOperands.nil?
        @operands = SkmEmptyList.instance
      else
        @operands = SkmPair.create_from_a(theOperands)
      end
      @operands_consumed = false
    end

    def evaluate(aRuntime)
      frame_change = false
      aRuntime.push_call(self)
      # $stderr.puts "\n Start of ProcedureCall#evaluate #{object_id.to_s(16)}"
      # $stderr.puts "  environment: #{aRuntime.environment.object_id.to_s(16)}, "
      if aRuntime.environment && aRuntime.environment.parent
        # $stderr.puts "Parent environment #{aRuntime.environment.parent.object_id.to_s(16)}, "
        # $stderr.puts aRuntime.environment.inspect
      end
      # $stderr.puts '  operator: ' + (operands.kind_of?(SkmLambda) ? "lambda #{object_id.to_s(16)}" : operator.inspect)
      # $stderr.puts '  original operands: ' + operands.inspect
      outcome, result = determine_callee(aRuntime)
      if outcome == :callee
        actuals = transform_operands(aRuntime)
        # $stderr.puts '  transformed operands: ' + actuals.inspect
        callee = result
        # if callee.kind_of?(SkmLambda)
          # aRuntime.push(callee.environment)
          # frame_change = true
        # end
        # $stderr.puts '  callee: ' + callee.inspect
        result = callee.call(aRuntime, actuals)
        operands_consumed = true
        # aRuntime.pop if frame_change
      end
      aRuntime.pop_call
      # $stderr.puts "\n End of ProcedureCall#evaluate #{object_id.to_s(16)}"
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

    private

    def determine_callee(aRuntime)
      case operator
        when SkmIdentifier
          callee = fetch_callee(aRuntime, operator)
        when ProcedureCall
          result = operator.evaluate(aRuntime)
          # If child proc call consumes the parent's operand, then we're done
          return [:result, result] unless result.callable? # if operands_consumed
          callee = result
          # callee = fetch_callee(aRuntime, result)
        when Primitive::PrimitiveProcedure
          callee = operator
        when SkmLambdaRep
          callee = operator.evaluate(aRuntime)
        when SkmLambda
          callee = operator
        else
          result = operator.evaluate(aRuntime)
          if result.kind_of?(Primitive::PrimitiveProcedure)
            callee = result
          else
            callee = fetch_callee(aRuntime, result)
          end
      end

      [:callee, callee]
    end

    def fetch_callee(aRuntime, var_key)
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
        # $stderr.puts aRuntime.inspect
        # $stderr.puts aRuntime.environment.size.inspect
        raise err, err_msg
      end
      callee = aRuntime.environment.fetch(var_key.value)
      # $stderr.puts "## CALL(#{var_key.value}) ###################"
      # $stderr.puts 'callee: ' + callee.inspect
      # $stderr.puts 'operator: ' + operator.inspect
      # $stderr.puts 'operands: ' + operands.inspect

      callee
    end

    def transform_operands(aRuntime)
      return [] if operands == SkmEmptyList.instance
      actuals = operands.to_a

      result = actuals.map do |actual|
        case actual
          when SkmVariableReference
            aRuntime.fetch(actual.child)
          else
            actual.evaluate(aRuntime)
        end
      end

      result.nil? ? [] : result
    end



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
        condition_result = alternate ? alternate.evaluate(aRuntime) : SkmUndefined.instance
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


  class SkmConditional < SkmMultiExpression
    # An array of couples [test, sequence]
    attr_reader :clauses
    attr_reader :alternate

    def initialize(aPosition, theClauses, anAlternate)
      super(aPosition)
      @clauses = theClauses
      @alternate = anAlternate
    end

    def evaluate(aRuntime)
      clause_matching = false
      result = nil

      clauses.each do |(test, consequent)|
        test_result = test.evaluate(aRuntime)
        next if test_result.boolean? && test_result.value == false

        clause_matching = true
        result = consequent.evaluate(aRuntime)
        break
      end

      unless clause_matching
        result = alternate ? alternate.evaluate(aRuntime) : SkmUndefined.instance
      end

      result
    end

    def quasiquote(aRuntime)
        quasi_clauses = clauses.map do |(test, consequent)|
          test_qq = test.quasiquote(aRuntime)
          consequent_qq = consequent.quasiquote(aRuntime)
          [test_qq, consequent_qq]
      end
      quasi_alternate = alternate ? alternate.quasiquote(aRuntime) : nil

      self.class.new(position, quasi_clauses, quasi_alternate)
    end

    def inspect
      result = inspect_prefix + '@test ' + test.inspect + ', '
      result << "@clauses \n"
      clauses.each do |(test, consequent)|
        result << '  '  << test.inspect << ' ' << consequent.inspect << "\n"
      end
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

  class SkmIterationSpec
    attr_reader :variable
    attr_reader :init_expr
    attr_reader :step_expr

    def initialize(anIdentifier, anInitialization, aStep)
      @variable = anIdentifier
      @init_expr = anInitialization
      @step_expr = aStep
    end
  end # class

class SkmDoExprBuilder
  attr_reader :bindings
  attr_reader :update_steps
  attr_reader :test
  attr_reader :do_result
  attr_reader :commands

  # 3 => iteration_spec_star, 6 => test, 7 => do_result, 9 => command_star

  def initialize(iterSpecs, aTest, doResult, theCommands)
    iteration_specs_set(iterSpecs)
    @test = aTest
    @do_result = doResult
    commands_set(theCommands)
  end

  def do_expression
    DoExpression.new(test, do_result, commands, update_steps)
  end

  private

  def iteration_specs_set(iterSpecs)
    @bindings = iterSpecs.map do |iter_spec|
        var = iter_spec.variable
        val = iter_spec.init_expr
        SkmBinding.new(var, val)
      end

    to_update = iterSpecs.select { |iter_spec| iter_spec.step_expr }
    if to_update
      steps = to_update.map do |iter_spec|
        SkmDelayedUpdateBinding.new(iter_spec.variable, iter_spec.step_expr)
      end
      if steps.size == 1
        @update_steps = steps[0]
      else
        @update_steps = SkmPair.create_from_a(steps)
      end
    else
      @update_steps = SkmEmptyList.instance
    end
  end

  def commands_set(theCommands)
    case theCommands.size
      when 0
        @commands = SkmEmptyList.instance
      when 1
        @commands = theCommands[0]
      else
        @commands = SkmSequencingBlock.new(SkmPair.create_from_a(theCommands))
    end
  end
end # class

  # Syntax outline:
  #  LPAREN DO LPAREN iteration_spec_star RPAREN
  #  LPAREN test do_result RPAREN
  #  command_star RPAREN
  # Semantics:
  #   Initialization:
  #   Set of variables is initialized (each with its init expression)
  #   Iteration:
  #     test expression is evaluation
  #       if false:
  #         command expressions are executed in order
  #         step expressions are executed and bound to the respective variable
  #         iteration resumes
  #       if true:
  #         the do_result expressions are excuted
  #         value of last expression is returned
  # ; (do ((vec (make-vector 5))
  # ; (i 0 (+ i 1)))
  # ; ((= i 5) vec)
  # ; (vector-set! vec i i))
  # Can be transformed into:
  #  (let* (
  #    ;; Variable init
  #    (vec (make-vector 5))
  #    (i 0)
  #    ;; Utility procedures
  #    (update-step (lambda ()
  #      (begin
  #        (set! i (+ i 1))
  #      )))
  #    (do-results (lambda ()
  #      (begin
  #        vec
  #      )))
  #    (do-commands (lambda ()
  #      (begin
  #        (vector-set! vec i i)
  #      ))))
  #    (begin
  #      (define do-iteration (lambda ()
  #        (if (= i 5)
  #          (do-results)
  #          (begin
  #            (do-commands)
  #            (update-step)
  #            (do-iteration))))))
  #      (do-iteration))
  class DoExpression < SkmMultiExpression
    # iterate until the test expression becomes true
    attr_reader :test

    # expression to execute in each iteration
    attr_reader :commands

    # expression to execute before return
    attr_reader :do_result

    # Update variables
    attr_reader :update_steps

    def initialize(aTest, doResult, theCommands, theUpdates)
      @test = aTest
      @do_result = doResult
      @commands = theCommands
      @update_steps = theUpdates
    end

    def evaluate(aRuntime)
      # require 'debug'
      loop do
        test_result = test.evaluate(aRuntime)
        if test_result.boolean? && test_result.value == false
          # Only #f is considered as false, everything else is true
          commands.evaluate(aRuntime) if commands
          if update_steps
            update_steps.evaluate(aRuntime)
            case update_steps
              when SkmEmptyList.instance
                ; Do nothing
              when SkmPair
                arr = update_steps.to_a
                arr.each { |delayed_binding| delayed_binding.do_it!(aRuntime) }
              else
                update_steps.do_it!(aRuntime)
            end
          end
        else
          break
        end
      end

      do_result ? do_result.evaluate(aRuntime) : SkmUndefined.instance
    end
  end # class

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


  # Parse tree representation of a Lambda
  # - Not bound to a frame (aka environment)
  # - Knows the parse representation of its embedded definitions
  # - Knows the parse representation of the body
  class SkmLambdaRep < SkmMultiExpression
    include DatumDSL

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
      SkmLambda.new(self, aRuntime)
    end

    def callable?
      true
    end

    def procedure?
      true
    end

    def call(aRuntime, theActuals)
      set_cond_environment(aRuntime.environment) # Last chance for anonymous lambda
      application = SkmProcedureExec.new(self)
      application.run!(aRuntime, theActuals)
    end

    def arity
      formals.arity
    end

    def required_arity
      formals.required_arity
    end

    alias eqv? equal?
    alias skm_equal? equal?

    def bound!(aFrame)
      set_cond_environment(aFrame)
    end

    def inspect
      result = inspect_prefix + "@object_id=#{object_id.to_s(16)}, "
      result << inspect_specific
      result << inspect_suffix
      result
    end

    def associations
      [:formals, :definitions, :sequence]
    end

    def bind_locals(aRuntime, theActuals)
      actuals =  theActuals
      count_actuals = actuals.size

      if (count_actuals < required_arity) ||
        ((count_actuals > required_arity) && !formals.variadic?)
        # $stderr.puts "Error"
        # $stderr.puts self.inspect
        raise StandardError, msg_arity_mismatch(theActuals)
      end
      return if count_actuals.zero? && !formals.variadic?
      bind_required_locals(aRuntime, theActuals)
      if formals.variadic?
        variadic_part_raw = actuals.drop(required_arity)
        variadic_part = variadic_part_raw.map do |actual|
          case actual
            when ProcedureCall
              actual.evaluate(aRuntime)
            when SkmQuotation
              actual.evaluate(aRuntime)
            else
              to_datum(actual)
          end
        end
        variadic_arg_name = formals.formals.last
        args_coll = SkmPair.create_from_a(variadic_part)
        a_def = SkmBinding.new(variadic_arg_name, args_coll)
        a_def.evaluate(aRuntime)
        aRuntime.add_binding(a_def.variable, a_def.value)
        # $stderr.puts "Tef #{a_def.inspect}"
        # $stderr.puts "Tef #{actuals.inspect}"
        # $stderr.puts "Tef #{variadic_part.inspect}"
        # $stderr.puts "Tef #{aProcedureCall.inspect}"
        # a_def.evaluate(aRuntime)
      end
      #aProcedureCall.operands_consumed = true
    end

    private

    # Purpose: bind each formal from lambda to an actual value from the call
    def bind_required_locals(aRuntime, theActuals)
      max_index = required_arity - 1
      actuals = theActuals
      formal_names = formals.formals.map(&:value)

      formals.formals.each_with_index do |arg_name, index|
        arg = actuals[index]
        if arg.nil?
          if actuals.empty? && formals.variadic?
            arg = SkmPair.create_from_a([])
          else
            raise StandardError, "Unbound variable: '#{arg_name.value}'"
          end
        end

        # IMPORTANT: execute procedure call in argument list now
        arg = arg.evaluate(aRuntime) if arg.kind_of?(ProcedureCall)
        unless arg.kind_of?(SkmElement)
          arg = to_datum(arg)
        end
        # a_def = SkmDefinition.new(position, arg_name, arg)
        a_def = SkmBinding.new(arg_name, arg)
        # $stderr.puts "Lambda #{object_id.to_s(16)}"
        # $stderr.puts "LOCAL #{arg_name.value} #{arg.inspect}"
        if arg.kind_of?(SkmVariableReference) && !formal_names.include?(arg.value)
          aRuntime.add_binding(arg_name, a_def)
        else
          aRuntime.add_binding(a_def.variable, a_def.evaluate(aRuntime))
        end
        break if index >= max_index
      end
    end

    def msg_arity_mismatch(actuals)
      # *** ERROR: wrong number of arguments for #<closure morph> (required 2, got 1)
      msg1 = "Wrong number of arguments for procedure "
      count_actuals = actuals.size
      msg2 = "(required #{required_arity}, got #{count_actuals})"
      msg1 + msg2
    end

    def inspect_specific
      result = ''
      result << '@formals ' + formals.inspect + ', '
      result << '@definitions ' + definitions.inspect + ', '
      result << '@sequence ' + sequence.inspect + inspect_suffix

      result
    end
  end # class




require 'forwardable'
require_relative 'skm_procedure_exec'

  class SkmLambda < SkmMultiExpression
    include DatumDSL
    extend Forwardable

    attr_reader :representation
    attr_reader :environment

    def_delegators(:@representation, :formals, :definitions, :sequence)

    def initialize(aRepresentation, aRuntime)
      @representation = aRepresentation
      @environment = aRuntime.environment
    end

    def evaluate(aRuntime)
      self
    end

    def callable?
      true
    end

    def procedure?
      true
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
    def call(aRuntime, theActuals)
      set_cond_environment(aRuntime.environment) # Last chance for anonymous lambda
      application = SkmProcedureExec.new(self)
      application.run!(aRuntime, theActuals)
    end

    def arity
      formals.arity
    end

    def required_arity
      formals.required_arity
    end

    alias eqv? equal?
    alias skm_equal? equal?

    def bound!(aFrame)
      set_cond_environment(aFrame)
    end

    def inspect
      result = inspect_prefix + "@object_id=#{object_id.to_s(16)}, "
      result << inspect_specific
      result << inspect_suffix
      result
    end

    def associations
      [:formals, :definitions, :sequence]
    end

    def bind_locals(aRuntime, theActuals)
      actuals =  theActuals
      count_actuals = actuals.size

      if (count_actuals < required_arity) ||
        ((count_actuals > required_arity) && !formals.variadic?)
        # $stderr.puts "Error"
        # $stderr.puts self.inspect
        raise StandardError, msg_arity_mismatch(theActuals)
      end
      return if count_actuals.zero? && !formals.variadic?
      bind_required_locals(aRuntime, theActuals)
      if formals.variadic?
        variadic_part_raw = actuals.drop(required_arity)
        variadic_part = variadic_part_raw.map do |actual|
          case actual
            when ProcedureCall
              actual.evaluate(aRuntime)
            when SkmQuotation
              actual.evaluate(aRuntime)
            else
              to_datum(actual)
          end
        end
        variadic_arg_name = formals.formals.last
        args_coll = SkmPair.create_from_a(variadic_part)
        a_def = SkmBinding.new(variadic_arg_name, args_coll)
        a_def.evaluate(aRuntime)
        aRuntime.add_binding(a_def.variable, a_def.value)
        # $stderr.puts "Tef #{a_def.inspect}"
        # $stderr.puts "Tef #{actuals.inspect}"
        # $stderr.puts "Tef #{variadic_part.inspect}"
        # $stderr.puts "Tef #{aProcedureCall.inspect}"
        # a_def.evaluate(aRuntime)
      end
      #aProcedureCall.operands_consumed = true
    end

    def evaluate_sequence(aRuntime)
      result = nil
      if sequence
        sequence.each do |cmd|
          begin
            if cmd.kind_of?(SkmLambda)
              result = cmd.dup_cond(aRuntime)
            else
              result = cmd.evaluate(aRuntime)
            end
          rescue NoMethodError => exc
            $stderr.puts self.inspect
            $stderr.puts sequence.inspect
            $stderr.puts cmd.inspect
            raise exc
          end
        end
      end

      result
    end

    def dup_cond(aRuntime)
      if environment
        result = self
      else
        twin = self.dup
        twin.set_cond_environment(aRuntime.environment)
        result = twin
      end

      result
    end

    def doppelganger(aRuntime)
      twin = self.dup
      twin.set_cond_environment(aRuntime.environment.dup)
      result = twin

      result
    end

    def set_cond_environment(theFrame)
      # $stderr.puts "Lambda #{object_id.to_s(16)}, env [#{environment.object_id.to_s(16)}]"
      # $stderr.puts "  Runtime environment: #{theFrame.object_id.to_s(16)}"
      # $stderr.puts "  Called from #{caller(1, 1)}"
      raise StandardError unless theFrame.kind_of?(SkmFrame)
      unless environment
        @environment = theFrame
        self.freeze
        # $stderr.puts "  Lambda's environment updated!"
      end
    end

    private

    # Purpose: bind each formal from lambda to an actual value from the call
    def bind_required_locals(aRuntime, theActuals)
      max_index = required_arity - 1
      actuals = theActuals
      formal_names = formals.formals.map(&:value)

      formals.formals.each_with_index do |arg_name, index|
        arg = actuals[index]
        if arg.nil?
          if actuals.empty? && formals.variadic?
            arg = SkmPair.create_from_a([])
          else
            raise StandardError, "Unbound variable: '#{arg_name.value}'"
          end
        end

        # IMPORTANT: execute procedure call in argument list now
        arg = arg.evaluate(aRuntime) if arg.kind_of?(ProcedureCall)
        unless arg.kind_of?(SkmElement)
          arg = to_datum(arg)
        end
        # a_def = SkmDefinition.new(position, arg_name, arg)
        a_def = SkmBinding.new(arg_name, arg)
        # $stderr.puts "Lambda #{object_id.to_s(16)}"
        # $stderr.puts "LOCAL #{arg_name.value} #{arg.inspect}"
        if arg.kind_of?(SkmVariableReference) && !formal_names.include?(arg.value)
          aRuntime.add_binding(arg_name, a_def)
        else
          aRuntime.add_binding(a_def.variable, a_def.evaluate(aRuntime))
        end
        break if index >= max_index
      end
    end

    def msg_arity_mismatch(actuals)
      # *** ERROR: wrong number of arguments for #<closure morph> (required 2, got 1)
      msg1 = "Wrong number of arguments for procedure "
      count_actuals = actuals.size
      msg2 = "(required #{required_arity}, got #{count_actuals})"
      msg1 + msg2
    end

    def inspect_specific
      #result = "@environment #{environment.object_id.to_s(16)}, "
      result = ''
      if environment && environment.parent
        result << "Parent environment #{environment.parent.object_id.to_s(16)}, "
        result << environment.inspect
      end
      result << '@formals ' + formals.inspect + ', '
      result << '@definitions ' + definitions.inspect + ', '
      result << '@sequence ' + sequence.inspect + inspect_suffix

      result
    end
  end # class
end # module
# End of file
