require 'frodo/properties/date_time'

module Frodo
  module Properties
    # Defines the Date Frodo type.
    class Date < Frodo::Properties::DateTime
      # The Frodo type name
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
