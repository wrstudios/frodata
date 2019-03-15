module Frodo
  module Properties
    # Defines the Integer Frodo type.
    class Integer < Frodo::Property
      include Frodo::Properties::Number

      # Returns the property value, properly typecast
      # @return [Integer,nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          @value.to_i
        end
      end

      # Sets the property value
      # @params new_value [to_i]
      def value=(new_value)
        validate(new_value.to_i)
        @value = new_value.to_i.to_s
      end

      # The Frodo type name
      def type
        'Edm.Int64'
      end

      private

      def exponent_size
        63
      end

      def min_value
        @min ||= -(2**exponent_size)
      end

      def max_value
        @max ||= (2**exponent_size)-1
      end
    end

    # Defines the Integer (16 bit) Frodo type.
    class Int16 < Integer
      # The Frodo type name
      def type
        'Edm.Int16'
      end

      private

      def exponent_size
        15
      end
    end

    # Defines the Integer (32 bit) Frodo type.
    class Int32 < Integer
      # The Frodo type name
      def type
        'Edm.Int32'
      end

      private

      def exponent_size
        31
      end
    end

    # Defines the Integer (64 bit) Frodo type.
    class Int64 < Integer; end

    # Defines the Byte Frodo type.
    class Byte < Integer
      # The Frodo type name
      def type
        'Edm.Byte'
      end

      private

      def exponent_size
        8
      end

      def min_value
        0
      end
    end

    # Defines the Signed Byte Frodo type.
    class SByte < Integer
      # The Frodo type name
      def type
        'Edm.SByte'
      end

      private

      def exponent_size
        7
      end
    end
  end
end