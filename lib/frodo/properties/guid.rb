module Frodo
  module Properties
    # Defines the GUID Frodo type.
    class Guid < Frodo::Property
      # The Frodo type name
      def type
        'Edm.Guid'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "#{value}"
      end
    end
  end
end