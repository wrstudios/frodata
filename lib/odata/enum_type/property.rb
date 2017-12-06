module OData
  class EnumType
    # Abstract base class for OData EnumTypes
    # @see [OData::EnumType]
    class Property < OData::Property
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
        @value = new_value.to_s
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
        unless members.keys.include?(value)
          raise ArgumentError, "Value must be one of #{members.keys}, but was: '#{value}'"
        end
      end

      def validate_options(options)
        raise ArgumentError, 'Type is required' unless options[:type]
      end
    end
  end
end
