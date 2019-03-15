module Frodo
  module Properties
    # Defines the DateTimeOffset Frodo type.
    class DateTimeOffset < Frodo::Properties::DateTime
      # The Frodo type name
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
