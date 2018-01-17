module OData4
  module Properties
    # Defines the Boolean OData4 type.
    class Boolean < OData4::Property
      # Returns the property value, properly typecast
      # @return [Boolean, nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          (@value == 'true' || @value == '1')
        end
      end

      # Sets the property value
      # @params new_value [Boolean]
      def value=(new_value)
        validate(new_value)
        @value = new_value.to_s
      end

      # The OData4 type name
      def type
        'Edm.Boolean'
      end

      private

      def validate(value)
        return if value.nil? && allows_nil?
        unless [0,1,'0','1','true','false',true,false].include?(value)
          raise ArgumentError, 'Value is outside accepted range: true or false'
        end
      end
    end
  end
end
