require 'odata/properties/date_time'

module OData
  module Properties
    # Defines the Date OData type.
    class TimeOfDay < OData::Properties::DateTime
      # The OData type name
      def type
        'Edm.TimeOfDay'
      end

      def url_value
        @value
      end

      protected

      def date_class
        ::Time
      end

      def strptime_format
        '%H:%M:%S.%L'
      end
    end
  end
end
