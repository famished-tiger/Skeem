# frozen_string_literal: true

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
  
  class SkmDelayedUpdateBinding < SkmBinding
    attr_reader :new_val
    
    def initialize(anIdentifier, aValue)
      super(anIdentifier, aValue)
    end
    
    def do_it!(aRuntime)
      aRuntime.update_binding(variable, new_val)
    end

    protected

    def binding_action(_runtime, _identifier, anExpression)
      @new_val = anExpression
    end
  end # class  
end # module
