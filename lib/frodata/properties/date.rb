require 'frodata/properties/date_time'

module FrOData
  module Properties
    # Defines the Date FrOData type.
    class Date < FrOData::Properties::DateTime
      # The FrOData type name
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
