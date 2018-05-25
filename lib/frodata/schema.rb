require 'frodata/schema/complex_type'
require 'frodata/schema/enum_type'

module FrOData
  class Schema
    # The schema's parent service
    attr_reader :service
    # The schema's metadata (i.e its XML definition)
    attr_reader :metadata

    # Creates a new schema.
    #
    # @param schema_definition [Nokogiri::XML] The schema's XML definition
    # @param service [FrOData::Service] The schema's parent service
    def initialize(schema_definition, service)
      @metadata = schema_definition
      @service = service
    end

    # Returns the schema's `Namespace` attribute (mandatory).
    # @return [String]
    def namespace
      @namespace ||= metadata.attributes['Namespace'].value
    end

    # Returns a list of actions defined by the schema.
    # @return [Array<String>]
    def actions
      @actions ||= metadata.xpath('//Action').map do |action|
        action.attributes['Name'].value
      end
    end

    # Returns a list of entities defined by the schema.
    # @return [Array<String>]
    def entity_types
      @entity_types ||= metadata.xpath('//EntityType').map do |entity|
        entity.attributes['Name'].value
      end
    end

    # Returns a list of `ComplexType`s defined by the schema.
    # @return [Hash<String, FrOData::Schema::ComplexType>]
    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').map do |entity|
        [
          entity.attributes['Name'].value,
          ComplexType.new(entity, self)
        ]
      end.to_h
    end

    # Returns a list of EnumTypes defined by the schema.
    # @return [Hash<String, FrOData::Schema::EnumType>]
    def enum_types
      @enum_types ||= metadata.xpath('//EnumType').map do |entity|
        [
          entity.attributes['Name'].value,
          EnumType.new(entity, self)
        ]
      end.to_h
    end

    # Returns a list of functions defined by the schema.
    # @return [Array<String>]
    def functions
      @functions ||= metadata.xpath('//Function').map do |function|
        function.attributes['Name'].value
      end
    end

    # Returns a list of type definitions defined by the schema.
    # @return [Array<String>]
    def type_definitions
      @typedefs ||= metadata.xpath('//TypeDefinition').map do |typedef|
        typedef.attributes['Name'].value
      end
    end

    # Returns a hash for finding an association through an entity type's defined
    # NavigationProperty elements.
    # @return [Hash<Hash<FrOData::NavigationProperty>>]
    def navigation_properties
      @navigation_properties ||= metadata.xpath('//EntityType').map do |entity_type_def|
        [
          entity_type_def.attributes['Name'].value,
          entity_type_def.xpath('./NavigationProperty').map do |nav_property_def|
            [
              nav_property_def.attributes['Name'].value,
              ::FrOData::NavigationProperty.build(nav_property_def)
            ]
          end.to_h
        ]
      end.to_h
    end

    # Get the property type for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @param property_name [to_s] the property name needed
    # @return [String] the name of the property's type
    def get_property_type(entity_name, property_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@Name='#{property_name}']").first.attributes['Type'].value
    end

    # Get the primary key for the supplied Entity.
    #
    # @param entity_name [to_s]
    # @return [String]
    def primary_key_for(entity_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Key/PropertyRef").first.attributes['Name'].value
    end

    # Get the list of properties and their various options for the supplied
    # Entity name.
    # @param entity_name [to_s]
    # @return [Hash]
    # @api private
    def properties_for_entity(entity_name)
      type_definition = metadata.xpath("//EntityType[@Name='#{entity_name}']").first
      raise ArgumentError, "Unknown EntityType: #{entity_name}" if type_definition.nil?
      properties_to_return = {}
      type_definition.xpath('./Property').each do |property_xml|
        property_name, property = process_property_from_xml(property_xml)
        properties_to_return[property_name] = property
      end
      properties_to_return
    end

    private

    def process_property_from_xml(property_xml)
      property_name = property_xml.attributes['Name'].value
      property_type = property_xml.attributes['Type'].value
      property_options = { service: service }

      property_type, value_type = property_type.split(/\(|\)/)
      if property_type == 'Collection'
        klass = ::FrOData::Properties::Collection
        property_options.merge(value_type: value_type)
      else
        klass = ::FrOData::PropertyRegistry[property_type]
      end

      if klass.nil?
        raise RuntimeError, "Unknown property type: #{property_type}"
      else
        property_options[:allows_nil] = false if property_xml.attributes['Nullable'] == 'false'
        property = klass.new(property_name, nil, property_options)
      end

      return [property_name, property]
    end
  end
end
