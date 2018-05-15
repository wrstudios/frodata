require 'frodata/properties/date_time'

module FrOData
  module Properties
    # Defines the Date FrOData type.
    class TimeOfDay < FrOData::Properties::DateTime
      # The FrOData type name
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
