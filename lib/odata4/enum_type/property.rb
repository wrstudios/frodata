module OData4
  class EnumType
    # Abstract base class for OData4 EnumTypes
    # @see [OData4::EnumType]
    class Property < OData4::Property
      # Returns the property value, properly typecast
      # @return [String, nil]
      def value
        if @value.nil? && allows_nil?
          nil
        else
          @value
        end
      end

      # Sets the property value
      # @params new_value [String]
      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value).andand.join(',')
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "#{type}'#{@value}'"
      end

      private

      def members
        raise NotImplementedError, 'Subclass must override'
      end

      def validate(value)
        return if value.nil? && allows_nil?
        values = parse_value(value)
        raise ArgumentError, 'Multiple values are not allowed for this property' if values.length > 1 && !is_flags?
        values.each do |value|
          unless members.keys.include?(value)
            raise ArgumentError, "Value must be one of #{members.keys}, but was: '#{value}'"
          end
        end
      end

      def parse_value(value)
        return nil if value.nil?
        value.split(',').map(&:strip)
      end
    end
  end
end
