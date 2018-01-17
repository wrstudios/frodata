module OData4
  module Properties
    # Defines the GUID OData4 type.
    class Guid < OData4::Property
      # The OData4 type name
      def type
        'Edm.Guid'
      end

      # Value to be used in URLs.
      # @return [String]
      def url_value
        "guid'#{value}'"
      end
    end
  end
end