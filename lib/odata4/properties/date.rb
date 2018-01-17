require 'odata4/properties/date_time'

module OData4
  module Properties
    # Defines the Date OData4 type.
    class Date < OData4::Properties::DateTime
      # The OData4 type name
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
