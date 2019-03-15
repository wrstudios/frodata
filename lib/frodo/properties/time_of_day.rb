require 'frodo/properties/date_time'

module Frodo
  module Properties
    # Defines the Date Frodo type.
    class TimeOfDay < Frodo::Properties::DateTime
      # The Frodo type name
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
