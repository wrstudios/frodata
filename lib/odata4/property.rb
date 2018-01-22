module OData4
  # OData4::Property represents an abstract property, defining the basic
  # interface and required methods, with some default implementations. All
  # supported property types should be implemented under the OData4::Properties
  # namespace.
  class Property
    # The property's name
    attr_reader :name
    # The property's value
    attr_accessor :value

    # Default intialization for a property with a name, value and options.
    # @param name [to_s]
    # @param value [to_s,nil]
    # @param options [Hash]
    def initialize(name, value, options = {})
      @name = name.to_s
      @value = value.nil? ? nil : value.to_s
      @options = default_options.merge(options)
    end

    # Abstract implementation, should return property type, based on
    # OData4::Service metadata in proper implementation.
    # @raise NotImplementedError
    def type
      raise NotImplementedError
    end

    # Provides for value-based equality checking.
    # @param other [value] object for comparison
    # @return [Boolean]
    def ==(other)
      self.value == other.value
    end

    # Whether the property permits a nil value.
    # (Default=true)
    # @return [Boolean]
    def allows_nil?
      options[:allows_nil]
    end

    # Whether the property uses strict validation.
    # (Default=false)
    # @return [Boolean]
    def strict?
      options[:strict]
    end

    # The configured concurrency mode for the property.
    # @return [String]
    def concurrency_mode
      @concurrecy_mode ||= options[:concurrency_mode]
    end

    # Value to be used in XML.
    # @return [String]
    def xml_value
      @value
    end

    # Value to be used in JSON.
    # @return [*]
    def json_value
      value
    end

    # Value to be used in URLs.
    # @return [String]
    def url_value
      @value
    end

    # Returns the XML representation of the property to the supplied XML
    # builder.
    # @param xml_builder [Nokogiri::XML::Builder]
    def to_xml(xml_builder)
      attributes = {
          'metadata:type' => type,
      }

      if value.nil?
        attributes['metadata:null'] = 'true'
        xml_builder['data'].send(name.to_sym, attributes)
      else
        xml_builder['data'].send(name.to_sym, attributes, xml_value)
      end
    end

    # Creates a new property instance from an XML element
    # @param property_xml [Nokogiri::XML::Element]
    # @param options [Hash]
    # @return [OData4::Property]
    def self.from_xml(property_xml, options = {})
      if property_xml.attributes['null'].andand.value == 'true'
        content = nil
      else
        content = property_xml.content
      end

      new(property_xml.name, content, options)
    end

    private

    def default_options
      {
        allows_nil:       true,
        concurrency_mode: :none,
        strict:           false
      }
    end

    def options
      @options
    end
  end
end
