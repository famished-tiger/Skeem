require_relative '../primitive_func'

module Skeem
  module Primitive
    module PrimitiveBuilder
      def add_primitives(aRuntime)
        add_arithmetic(aRuntime)
      end
      
      private
      
      def add_arithmetic(aRuntime)
        def_func(aRuntime, create_plus)
      end
      
      def create_plus()
        plus_code = ->(runtime, arglist) do
          operands = arglist.to_eval_enum(runtime)
          raw_result = operands.reduce(0) do |interim, elem|
            interim += elem.value
          end
          SExprInteger.create(raw_result)
        end

        ['+', plus_code]
      end
      
      def def_func(aRuntime, aPair)
        func = PrimitiveFunc.new(aPair.first, aPair.last)
        define(aRuntime, func.identifier, func)
      end

      def define(aRuntime, aKey, anEntry)
        aRuntime.define(aKey, anEntry)
      end
    end # module
  end # module
end # module