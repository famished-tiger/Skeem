require_relative 's_expr_nodes'

module Skeem
  module Convertible
    # Convert Ruby object into its Skeem counterpart
    def to_skm(native_obj)
      case native_obj
        when TrueClass, FalseClass
          SkmBoolean.create(native_obj)
        when Float
          SkmReal.create(native_obj)
        when Integer
          SkmInteger.create(native_obj)
      end
    end
  end # module
end # module