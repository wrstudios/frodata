module FrOData
  module Properties
    # Defines the DateTimeOffset FrOData type.
    class DateTimeOffset < FrOData::Properties::DateTime
      # The FrOData type name
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
