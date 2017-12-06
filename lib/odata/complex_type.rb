require 'odata/complex_type/property'

module OData
  # ComplexTypes are used in OData to either encapsulate richer data types for
  # use as Entity properties. ComplexTypes are composed of properties the same
  # way that Entities are and, so, the interface for working with the various
  # properties of a ComplexType mimics that of Entities.
  class ComplexType
    # Creates a new ComplexType based on the supplied options.
    # @param type_xml [Nokogiri::XML::Element]
    # @param service [OData::Service]
    # @return [self]
    def initialize(type_definition, service)
      @type_definition = type_definition
      @service         = service
    end

    # The name of the ComplexType
    # @return [String]
    def name
      @name ||= type_definition.attributes['Name'].value
    end

    # Returns the namespaced type for the ComplexType.
    # @return [String]
    def type
      "#{namespace}.#{name}"
    end

    # Returns the namespace this ComplexType belongs to.
    # @return [String]
    def namespace
      @namespace ||= service.namespace
    end

    # Returns this ComplexType's properties.
    # @return [Hash<String, OData::Property>]
    def properties
      @properties ||= collect_properties
    end

    # Returns a list of this ComplexType's property names.
    # @return [Array<String>]
    def property_names
      @property_names ||= properties.keys
    end

    # Returns the property class that implements this `ComplexType`.
    # @return [Class < OData::ComplexType::Property]
    def property_class
      @property_class ||= lambda { |type, complex_type|
        klass = Class.new ::OData::ComplexType::Property
        klass.send(:define_method, :type) { type }
        klass.send(:define_method, :complex_type) { complex_type }
        klass
      }.call(type, self)
    end

    private

    def service
      @service
    end

    def type_definition
      @type_definition
    end

    def collect_properties
      Hash[type_definition.xpath('./Property').map do |property_xml|
        property_name, property = service.send(:process_property_from_xml,property_xml)
        [property_name, property]
      end]
    end
  end
end
