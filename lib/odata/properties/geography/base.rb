module OData
  module Properties
    module Geography
      class Base < OData::Property
        # Initializes a geography property.
        # @param name [to_s]
        # @param value [Hash|Array|to_s|nil]
        # @param options [Hash]
        def initialize(name, value, options = {})
          super(name, value, options)
          self.value = value
        end

        # Sets the value of the property.
        # @param value [Hash|Array|to_s|nil]
        def value=(value)
          if value.nil? && allows_nil?
            @value = nil
          elsif value.is_a?(Hash)
            @value = value['coordinates']
          elsif value.is_a?(Array)
            @value = value
          else
            @value = parse_value(value.to_s)
          end
        end

        # Value to be used in URLs.
        # @return [String]
        def url_value
          "geography'SRID=0;#{type_name}(#{value.join(' ')})'"
        end

        # Value to be used in JSON.
        # @return [Hash]
        def json_value
          {
            type: type_name,
            coordinates: value
          }
        end

        def xml_value
          @value.join(' ')
        end

        # Returns the XML representation of the property to the supplied XML
        # builder.
        # @param xml_builder [Nokogiri::XML::Builder]
        def to_xml(xml_builder)
          attributes = { 'metadata:type' => type }

          xml_builder['data'].send(name.to_sym, attributes) do
            xml_builder['gml'].send(type_name) do
              xml_builder['gml'].pos(nil, xml_value)
            end
          end
        end

        # Creates a new property instance from an XML element
        # @param property_xml [Nokogiri::XML::Element]
        # @param options [Hash]
        # @return [OData::Properties::Geography]
        def self.from_xml(property_xml, options = {})
          if property_xml.attributes['null'].andand.value == 'true'
            content = nil
          else
            content = parse_xml(property_xml)
          end

          new(property_xml.name, content, options)
        end

        private

        def type_name
          self.class.name.split('::').last
        end

        def parse_value(value)
          if value =~ /^geography'SRID=(\d+);(\w+)\((.+)\)'$/
            $2 == type_name or raise ArgumentError, "Invalid geography type '#{$2}'"
            $3.split(' ').map(&:to_f)
          else
            raise ArgumentError, "Invalid geography value '#{value}'"
          end
        end

        def self.parse_xml(property_xml)
          property_xml.xpath('//pos').map do |el|
            el.content.split(' ').map(&:to_f)
          end.flatten
        end
      end
    end
  end
end
