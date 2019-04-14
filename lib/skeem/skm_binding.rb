require_relative 'skm_element'

module Skeem
  
  # An identifier that is not a syntactic keyword can be used as a variable.
  # A variable may give a name to value that is bound (i.e. associated)
  # to that variable.
  class SkmBinding < SkmElement
    # @return [SkmIdentifier] The identifier that is bound the value.
    attr_reader(:variable)
    
    # @return [SkmElement] The Skeem object that is associated with the variable.
    attr_reader(:value)
    
    # Constructor
    # @param anIdentifier [SkmIdentifier] The variable name
    # @param aValue [SkmElement] The value to bind to the variable.
    def initialize(anIdentifier, aValue)
      @variable = anIdentifier
      @value = aValue
    end
    
    def evaluate(aRuntime)
      name = variable.evaluate(aRuntime)

      if value.kind_of?(SkmVariableReference)
        other_name = value.variable.evaluate(aRuntime)
        if name.value != other_name.value
          entry = aRuntime.fetch(other_name)
          result = value.evaluate(aRuntime)
          if entry.callable?
            @value = entry
          end
        else
          # same name in definiens
          raise StandardError
        end
      else
        result = value.evaluate(aRuntime)
      end
      
=begin      
      aRuntime.add_binding(var_key, self)
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
=end
      binding_action(aRuntime, name, result)
      result
    end
    
    protected
    
    def binding_action(aRuntime, anIdentifier, anExpression)
      aRuntime.add_binding(anIdentifier, anExpression)
    end

    def inspect_specific
      result = variable.inspect
      if value
        result << ', ' << value.inspect
      end

      result
    end    
    
  end # class
  

  class SkmUpdateBinding < SkmBinding
  
    protected
    
    def binding_action(aRuntime, anIdentifier, anExpression)
      aRuntime.update_binding(anIdentifier, anExpression)
    end    
  end # class
end # module
