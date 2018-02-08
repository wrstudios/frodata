module OData4
  class Schema
    # The schema's parent service
    attr_reader :service
    # The schema's metadata (i.e its XML definition)
    attr_reader :metadata

    # Creates a new schema.
    #
    # @param schema_definition [Nokogiri::XML] The schema's XML definition
    # @param service [OData4::Service] The schema's parent service
    def initialize(schema_definition, service)
      @metadata = schema_definition
      @service = service
    end

    # The schema's `Namespace` attribute (mandatory).
    # @return [String]
    def namespace
      @namespace ||= metadata.attributes['Namespace'].value
    end

    # Returns a list of entities defined by the schema.
    # @return Array<String>
    def entity_types
      @entity_types ||= metadata.xpath('//EntityType').map do |entity|
        entity.attributes['Name'].value
      end
    end

    # Returns a hash of `EntitySet` names and their `EntityType`s.
    # @return Hash<String, String>
    def entity_sets
      @entity_sets ||= metadata.xpath('//EntityContainer/EntitySet').map do |entity|
        [
          entity.attributes['Name'].value,
          entity.attributes['EntityType'].value.gsub("#{namespace}.", '')
        ]
      end.to_h
    end

    # Returns a list of `ComplexType`s defined by the schema.
    # @return [Hash<String, OData4::ComplexType>]
    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').map do |entity|
        [
          entity.attributes['Name'].value,
          ::OData4::ComplexType.new(entity, self)
        ]
      end.to_h
    end

    # Returns a list of EnumTypes defined by the schema.
    # @return [Hash<String, OData4::EnumType>]
    def enum_types
      @enum_types ||= metadata.xpath('//EnumType').map do |entity|
        [
          entity.attributes['Name'].value,
          ::OData4::EnumType.new(entity, self)
        ]
      end.to_h
    end

    # Returns a hash for finding an association through an entity type's defined
    # NavigationProperty elements.
    # @return [Hash<Hash<OData4::NavigationProperty>>]
    def navigation_properties
      @navigation_properties ||= metadata.xpath('//EntityType').collect do |entity_type_def|
        entity_type_name = entity_type_def.attributes['Name'].value
        [
            entity_type_name,
            entity_type_def.xpath('./NavigationProperty').collect do |nav_property_def|
              [
                  nav_property_def.attributes['Name'].value,
                  ::OData4::NavigationProperty.build(nav_property_def)
              ]
            end.to_h
        ]
      end.to_h
    end
  end
end
