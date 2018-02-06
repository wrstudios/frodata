module OData4
  module Properties
    # Defines common behavior for OData4 numeric types.
    module Number
      private

      def validate(value)
        if value > max_value || value < min_value
          validation_error "Value is outside accepted range: #{min_value} to #{max_value}"
        end
      end
    end
  end
end
