require_relative 's_expr_nodes'

module Skeem
  module Convertible
    # Convert Ruby object into its Skeem counterpart
    def to_skm(native_obj)
      return native_obj if native_obj.kind_of?(SkmElement)

      case native_obj
        when TrueClass, FalseClass
          SkmBoolean.create(native_obj)
        when Float
          SkmReal.create(native_obj)
        when Integer
          SkmInteger.create(native_obj)
        when String
          SkmString.create(native_obj)
        else
          raise StandardError, "No conversion of #{native_obj.class}"
      end
    end
  end # module
end # module