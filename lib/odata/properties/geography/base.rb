module OData
  module Properties
    module Geography
      class Base < OData::Property
        # The SRID (Spatial Reference ID) of this property.
        attr_accessor :srid

        # The default SRID (same as used by GPS)
        DEFAULT_SRID = 4326

        # Initializes a geography property.
        #
        # Special options available for geographic types:
        #
        # +srid+: the SRID (spatial reference ID) of the
        #         coordinate system being used.
        #         Defaults to 4326 (same as GPS).
        #
        # @param name [to_s]
        # @param value [Hash|Array|to_s|nil]
        # @param options [Hash]
        def initialize(name, value, options = {})
          super(name, value, options)
          self.value = value
          self.srid  = srid || options[:srid] || DEFAULT_SRID
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

        # The name of the SRS (Spatial Reference System) used.
        # Basically, the SRID in URI/URL form.
        # @return [String]
        def srs_name
          if srid == DEFAULT_SRID
            "http://www.opengis.net/def/crs/EPSG/0/#{srid}"
          else
            raise NotImplementedError, "Unsupported SRID #{srid}"
          end
        end

        # The name of the CRS (Coordinate Reference System) used.
        # Used in GeoJSON representation
        # @return [String]
        def crs_name
          if srid == DEFAULT_SRID
            "EPSG:#{srid}"
          else
            raise NotImplementedError, "Unsupported SRID #{srid}"
          end
        end

        # The full CRS representation as used by GeoJSON
        # @return [Hash]
        def crs
          {
            type: 'name',
            properties: { name: crs_name }
          }
        end

        # Value to be used in URLs.
        # @return [String]
        def url_value
          "geography'SRID=#{srid};#{type_name}(#{to_s})'"
        end

        # Value to be used in JSON.
        # @return [Hash]
        def json_value
          {
            type: type_name,
            coordinates: value,
            crs: crs
          }
        end

        # Returns the XML representation of the property to the supplied XML
        # builder.
        # @param xml_builder [Nokogiri::XML::Builder]
        def to_xml(xml_builder)
          attributes = { 'metadata:type' => type }
          type_attrs = { 'gml:srsName' => srs_name }

          xml_builder['data'].send(name.to_sym, attributes) do
            xml_builder['gml'].send(type_name, type_attrs) do
              value_to_xml(xml_value, xml_builder)
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
            options.merge!(srid: srid_from_xml(property_xml))
          end

          new(property_xml.name, content, options)
        end

        protected

        def type_name
          self.class.name.split('::').last
        end

        def parse_value(value)
          if value =~ /^geography'(SRID=(\d+);)+(\w+)\((.+)\)'$/
            $3 == type_name or raise ArgumentError, "Invalid geography type '#{$3}'"
            self.srid = $1 ? $2.to_i : DEFAULT_SRID
            from_s($4)
          else
            raise ArgumentError, "Invalid geography value '#{value}'"
          end
        end

        # Recursively turn a JSON-like data structure into XML
        def value_to_xml(value, xml_builder)
          if value.is_a?(Hash)
            value.each do |key, val|
              xml_builder['gml'].send(key) do
                value_to_xml(val, xml_builder)
              end
            end
          elsif value.is_a?(Array)
            value.each do |val|
              value_to_xml(val, xml_builder)
            end
          else
            xml_builder.text(value)
          end
        end

        # Extract the SRID from a GML element's `srsName` attribute
        def self.srid_from_xml(property_xml)
          gml_elem = property_xml.element_children.first
          srs_attr = gml_elem.attributes['srsName']
          if srs_attr
            srs_attr.value.split(/[\/:]/).last.to_i
          end
        end
      end
    end
  end
end
