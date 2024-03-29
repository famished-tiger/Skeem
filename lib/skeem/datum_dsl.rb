# frozen_string_literal: true

require_relative 'skm_simple_datum'
require_relative 'skm_compound_datum'
require_relative 'skm_pair'

module Skeem
  # Mixin module that provides factory methods that ease the conversion of
  # Ruby literals into SkmSimpleDatum or SkmCompoundDatum objects.
  module DatumDSL
    def boolean(aBoolean)
      return aBoolean if aBoolean.kind_of?(SkmBoolean)

      case aBoolean
        when TrueClass, FalseClass
          SkmBoolean.create(aBoolean)
        when /^#t(?:rue)?|true$/
          SkmBoolean.create(true)
        when /^#f(?:alse)?|false$/
          SkmBoolean.create(false)
        else
          raise StandardError, aBoolean.inspect
      end
    end

    def integer(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmInteger)

      case aLiteral
        when Integer
          SkmInteger.create(aLiteral)
        when /^[+-]?\d+$/
          SkmInteger.create(aLiteral.to_i)
        else
          raise StandardError, aLiteral.inspect
      end
    end

    def rational(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmRational)

      case aLiteral
        when Rational
          SkmRational.create(aLiteral)
        when /^[+-]?\d+\/\d+$/
          SkmRational.create(Rational(aLiteral))
        else
          raise StandardError, aLiteral.inspect
      end
    end

    def real(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmReal)

      case aLiteral
        when Numeric
          SkmReal.create(aLiteral)
        when /^[+-]?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?$/
          SkmReal.create(aLiteral.to_f)
        else
          raise StandardError, aLiteral.inspect
      end
    end

    def char(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmChar)

      case aLiteral
        when Numeric
          SkmChar.create_from_int(aLiteral)
        when String
          value = aLiteral.empty? ? '' : aLiteral.chr
          SkmChar.create(value)
        when SkmString
          value = aLiteral.value.empty? ? '' : aLiteral.value.chr
          SkmChar.create(value)
        else
          raise StandardError, aLiteral.inspect
      end
    end

    def string(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmString)

      case aLiteral
        when String
          SkmString.create(aLiteral)
        when SkmIdentifier
          SkmString.create(aLiteral.value)
        else
          SkmString.create(aLiteral.to_s)
      end
    end

    def identifier(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmIdentifier)

      case aLiteral
        when String
          SkmIdentifier.create(aLiteral)
        when SkmString
          SkmIdentifier.create(aLiteral.value)
        else
          raise StandardError, aLiteral.inspect
      end
    end

    alias symbol identifier

    def list(aLiteral)
      case aLiteral
        when Array
          SkmPair.create_from_a(to_datum(aLiteral))
        when SkmPair
          SkmPair.create_from_a(to_datum(aLiteral.to_a))
        else
          SkmPair.new(to_datum(aLiteral), SkmEmptyList.instance)
        end
    end

    def vector(aLiteral)
      case aLiteral
        when Array
          SkmVector.new(to_datum(aLiteral))
        when SkmVector
          SkmVector.new(to_datum(aLiteral.members))
        else
          SkmVector.new([to_datum(aLiteral)])
        end
    end

    # Conversion from Ruby object value to Skeem datum
    def to_datum(aLiteral)
      return aLiteral if aLiteral.kind_of?(SkmSimpleDatum)
      return vector(aLiteral.members) if aLiteral.kind_of?(SkmVector)
      return aLiteral if aLiteral.kind_of?(Primitive::PrimitiveProcedure)

      case aLiteral
        when Array
          aLiteral.map { |elem| to_datum(elem) }
        when Integer
          SkmInteger.create(aLiteral)
        when Rational
          SkmRational.create(aLiteral)
        when Float
          SkmReal.create(aLiteral)
        when TrueClass, FalseClass
          SkmBoolean.create(aLiteral)
        when String
          parse_literal(aLiteral)
        when SkmPair # Special case: not a PORO literal
          # One assumes that a Skeem list contains only Skeem datum objects
          SkmPair.create_from_a(aLiteral.to_a)
        when SkmUndefined
          aLiteral
        else
          raise StandardError, aLiteral.inspect
      end
    end

    private

    def parse_literal(aLiteral)
      # if aLiteral =~ /^#t(?:rue)?|true$/
        # boolean(aLiteral)
      # elsif aLiteral =~ /^#f(?:alse)?|false$/
        # boolean(aLiteral)
      # elsif aLiteral =~ /^[+-]?\d+\/\d+$/
        # rational(aLiteral)
      # elsif aLiteral =~ /^[+-]?\d+$/
        # integer(aLiteral)
      # elsif aLiteral =~ /^[+-]?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?$/
        # real(aLiteral)
      # else
        # string(aLiteral)
      # end

      case aLiteral
        when /^#t(?:rue)?|true$/, /^#f(?:alse)?|false$/
          boolean(aLiteral)
        when /^[+-]?\d+\/\d+$/
          rational(aLiteral)
        when /^[+-]?\d+$/
          integer(aLiteral)
        when /^[+-]?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?$/
          real(aLiteral)
        else
          string(aLiteral)
      end
    end
  end # module
end # module
