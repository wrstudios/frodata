module OData
  module Properties
    # Defines the DateTimeOffset OData type.
    class DateTimeOffset < OData::Properties::DateTime
      # The OData type name
      def type
        'Edm.DateTimeOffset'
      end

      def url_value
        value
      end

      protected

      def datetime_format
        '%Y-%m-%dT%H:%M:%S%:z'
      end
    end
  end
end
