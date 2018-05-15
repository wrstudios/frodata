module FrOData
  module Properties
    module Geography
      class Point < Base
        def type
          'Edm.GeographyPoint'
        end

        def coords_to_s
          value.join(' ')
        end

        def coords_from_s(str)
          str.split(' ').map(&:to_f)
        end

        def xml_value
          { pos: coords_to_s }
        end

        private

        def self.parse_xml(property_xml)
          property_xml.xpath('//pos').map do |el|
            el.content.split(' ').map(&:to_f)
          end.flatten
        end
      end
    end
  end
end
