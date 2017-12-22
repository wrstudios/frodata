module OData
  module Properties
    module Geography
      class Point < Base
        def type
          'Edm.GeographyPoint'
        end

        def xml_value
          to_s
        end

        def to_s
          value.join(' ')
        end

        def from_s(str)
          str.split(' ').map(&:to_f)
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