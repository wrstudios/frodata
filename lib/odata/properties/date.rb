require 'odata/properties/date_time'

module OData
  module Properties
    # Defines the Date OData type.
    class Date < OData::Properties::DateTime
      # The OData type name
      def type
        'Edm.Date'
      end

      def url_value
        @value
      end

      protected

      def date_class
        ::Date
      end

      def strptime_format
        '%Y-%m-%d'
      end
    end
  end
end
