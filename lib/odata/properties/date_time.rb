module OData
  module Properties
    # Defines the DateTime OData type.
    class DateTime < OData::Property
      # Returns the property value, properly typecast
      # @return [DateTime, nil]
      def value
        if (@value.nil? || @value.empty?) && allows_nil?
          nil
        else
          begin
            date_class.strptime(@value, strptime_format)
          rescue ArgumentError
            date_class.parse(@value)
          end
        end
      end

      # Sets the property value
      # @params new_value [DateTime]
      def value=(new_value)
        validate(new_value)
        @value = parse_value(new_value)
      end

      # The OData type name
      def type
        'Edm.DateTime'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "datetime'#{value}'"
      end

      protected

      # Specifies date/time implementation to use
      def date_class
        ::DateTime
      end

      # Specifies the date/time format string used for `strptime`
      def strptime_format
        '%Y-%m-%dT%H:%M:%S.%L'
      end

      def validate(value)
        begin
          return if value.nil? && allows_nil?
          return if value.is_a?(date_class)
          date_class.strptime(value, strptime_format)
        rescue
          raise ArgumentError, 'Value is not a date time format that can be parsed'
        end
      end

      def parse_value(value)
        return value if value.nil? && allows_nil?
        parsed_value = value
        parsed_value = date_class.parse(value) unless value.is_a?(date_class)
        parsed_value.strftime(strptime_format)
      end
    end
  end
end
