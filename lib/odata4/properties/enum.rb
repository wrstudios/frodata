module OData4
  module Properties
    # Abstract base class for OData4 EnumTypes
    # @see [OData4::Schema::EnumType]
    class Enum < OData4::Property
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
        parsed_value = validate(new_value)
        @value = is_flags? ? parsed_value : parsed_value.first
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
        return [] if value.nil? && allows_nil?
        values = parse_value(value)

        if values.length > 1 && !is_flags?
          raise ArgumentError, 'Multiple values are not allowed for this property'
        end

        values.map do |value|
          if members.keys.include?(value)
            members[value]
          elsif members.values.include?(value)
            value
          else
            validation_error "Value must be one of #{members.to_a}, but was: '#{value}'"
          end
        end.compact
      end

      def parse_value(value)
        return nil if value.nil?
        value.to_s.split(',').map(&:strip).map do |val|
          val =~ /^[0-9]+$/ ? val.to_i : val
        end
      end
    end
  end
end
