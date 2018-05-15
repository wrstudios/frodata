module FrOData
  module Properties
    # Defines the Float FrOData type.
    class Float < FrOData::Property
      include FrOData::Properties::Number

      # Returns the property value, properly typecast
      # @return [Float,nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          @value.to_f
        end
      end

      # Sets the property value
      # @params new_value [to_f]
      def value=(new_value)
        validate(new_value.to_f)
        @value = new_value.to_f.to_s
      end

      # The FrOData type name
      def type
        'Edm.Double'
      end

      private

      def min_value
        @min ||= -(1.7 * (10**308))
      end

      def max_value
        @max ||= (1.7 * (10**308))
      end
    end

    # Defines the Double (Float) FrOData type.
    class Double < FrOData::Properties::Float; end

    # Defines the Single (Float) FrOData type.
    class Single < FrOData::Properties::Float
      # The FrOData type name
      def type
        'Edm.Single'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "#{value}F"
      end

      private

      def min_value
        @min ||= -(3.4 * (10**38))
      end

      def max_value
        @max ||= (3.4 * (10**38))
      end
    end
  end
end