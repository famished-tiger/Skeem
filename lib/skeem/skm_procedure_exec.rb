require_relative 'runtime'

module Skeem
  class SkmProcedureExec
    attr_reader :frame
    attr_reader :definition

    def initialize(aLambda)
      @definition = aLambda
      @frame = SkmFrame.new(definition.environment)
      # $stderr.puts "New SkmProcedureExec"
      # $stderr.puts "  frame = #{frame.object_id.to_s(16)}"
      # $stderr.puts "  Lambda = #{aLambda.object_id.to_s(16)}"
    end

    # @param theActuals [Array<SkmElement>]
    def run!(aRuntime, theActuals)
      runtime = aRuntime
      runtime.push(frame)
      definition.bind_locals(runtime, theActuals)
      evaluate_defs(aRuntime)
      # definition.evaluate_defs(runtime)
      # $stderr.puts "Locals"
      # $stderr.puts frame.bindings.keys.join(', ')      
      result = definition.evaluate_sequence(runtime)
      runtime.pop
      # $stderr.puts "Lambda result: #{result.object_id.to_s(16)}" if result.kind_of?(SkmLambda)
      
      result
    end
    
    private
    
    def evaluate_defs(aRuntime)
      definition.definitions.each do |bndng|
        var = bndng.variable.evaluate(aRuntime)
        val = bndng.value.evaluate(aRuntime)
        frame.add_binding(var, val)
      end    
    end
  end # class
end # module