module OData4
  module Properties
    # Defines the Float OData4 type.
    class Float < OData4::Property
      include OData4::Properties::Number

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

      # The OData4 type name
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

    # Defines the Double (Float) OData4 type.
    class Double < OData4::Properties::Float; end

    # Defines the Single (Float) OData4 type.
    class Single < OData4::Properties::Float
      # The OData4 type name
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