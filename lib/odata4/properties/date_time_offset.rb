module OData4
  module Properties
    # Defines the DateTimeOffset OData4 type.
    class DateTimeOffset < OData4::Properties::DateTime
      # The OData4 type name
      def type
        'Edm.DateTimeOffset'
      end

      protected

      def strptime_format
        '%Y-%m-%dT%H:%M:%S%:z'
      end
    end
  end
end
