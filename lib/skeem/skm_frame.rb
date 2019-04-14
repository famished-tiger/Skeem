require_relative 'skm_simple_datum'

module Skeem
  # A frame is a set of bindings of the form { String => SkmElement }.
  # It associate to each identifier (as String) a Skeem object.
  class SkmFrame
    # @return [SkmFrame, nil] Link to parent frame (if any).
    attr_reader :parent

    # @return [Hash{String => SkmElement}] Map of variable names => values.
    attr_reader(:bindings)

    # Constructor
    # @param parentFrame[SkmFrame] Parent frame of this one.
    def initialize(parentFrame = nil)
      @bindings = {}
      @parent = parentFrame
    end
    
    # Add a binding to this frame.
    # There is no check that the variable name is already in use.
    # @param anIdentifier [String, SkmIdentifier] The variable name
    # @param anExpression [SkmElement] The Skeem expression to bind
    def add_binding(anIdentifier, anExpression)
      bind(valid_identifier(anIdentifier), anExpression)
    end

    # Update the value of an existing variable.
    # @param anIdentifier [String, SkmIdentifier] The variable name.
    # @param anExpression [SkmElement] The Skeem expression to bind
    def update_binding(anIdentifier, anExpression)
      variable = valid_identifier(anIdentifier) 
      if bindings.include?(variable)
        bind(variable, anExpression)
      elsif parent
        parent.update_binding(variable, anExpression)
      end
    end

    # Retrieve the value of an existing variable.
    # @param anIdentifier [String, SkmIdentifier] The variable name.
    # @return [SkmElement]
    def fetch(anIdentifier)
      variable = valid_identifier(anIdentifier)
      found = bindings[variable]
      if found.nil? && parent
        found = parent.fetch(variable)
      end

      found
    end

    # Tell  the value of an existing variable.
    # @param anIdentifier [String, SkmIdentifier] The variable name.
    # @return [Boolean]    
    def include?(anIdentifier)
      variable = valid_identifier(anIdentifier)
      my_result = bindings.include?(variable)
      if my_result == false && parent
        my_result = parent.include?(variable)
      end

      my_result
    end

    # @return [Boolean]
    def empty?
      my_result = bindings.empty?
      if my_result && parent
        my_result = parent.empty?
      end

      my_result
    end

    # @return [Integer]
    def size
      my_result = bindings.size
      my_result += parent.size if parent

      my_result
    end

    # The number of parents this frame has.
    # @return [Integer] The nesting levels
    def depth
      count = 0

      curr_frame = self
      while curr_frame.parent
        count += 1
        curr_frame = curr_frame.parent
      end

      count
    end

    # @return [String]
    def inspect
      result = ''
      if parent
        result << parent.inspect
      else
        return "\n"
      end
      result << "\n----\n"
      bindings.each_pair do |key, expr|
        result << "#{key.inspect} => #{expr.inspect}\n"
      end

      result
    end
    
    private
    
    def valid_identifier(anIdentifier)
      case anIdentifier
        when String
          anIdentifier
        when SkmIdentifier
          anIdentifier.value
        else
          klass = anIdentifier.class.to_s
          err_msg = "Invalid identifier: #{anIdentifier} has type #{klass}."
          raise StandardError, err_msg
      end
    end
    
    def bind(anIdentifier, anExpression)
      @bindings[anIdentifier] = anExpression
      
      # Notify the value that it is bound to a variable from this frame.
      anExpression.bound!(self)    
    end
    
  end # class
end # module