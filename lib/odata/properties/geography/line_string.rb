module OData
  module Properties
    module Geography
      class LineString < Base
        def type
          'Edm.GeographyLineString'
        end

        def coords_to_s
          value.map { |pos| pos.join(' ') }.join(',')
        end

        def coords_from_s(str)
          str.split(',').map { |pos| pos.split(' ').map(&:to_f) }
        end

        def xml_value
          value.map do |coords|
            { pos: coords.join(' ') }
          end
        end

        private

        def self.parse_xml(property_xml)
          property_xml.xpath('//pos').map do |el|
            el.content.split(' ').map(&:to_f)
          end
        end
      end
    end
  end
end
