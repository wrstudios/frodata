require 'odata4/properties/date_time'

module OData4
  module Properties
    # Defines the Date OData4 type.
    class TimeOfDay < OData4::Properties::DateTime
      # The OData4 type name
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
