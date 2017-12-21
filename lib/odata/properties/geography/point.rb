module OData
  module Properties
    module Geography
      class Point < Base
        def type
          'Edm.GeographyPoint'
        end
      end
    end
  end
end
