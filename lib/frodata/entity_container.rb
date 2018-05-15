module FrOData
  #
  class EntityContainer
    # The EntityContainer's parent service
    attr_reader :service
    # The EntityContainer's metadata
    attr_reader :metadata

    # Creates a new EntityContainer
    # @param service [FrOData::Service] The entity container's parent service
    def initialize(service)
      @metadata = service.metadata.xpath('//EntityContainer').first
      @service  = service
    end

    # The EntityContainer's surrounding Schema
    # @return [Nokogiri::XML]
    def schema
      @schema ||= metadata.ancestors('Schema').first
    end

    # Returns the EntityContainer's namespace.
    # @return [String]
    def namespace
      @namespace ||= schema.attributes['Namespace'].value
    end

    # Returns the EntityContainer's name.
    # @return [String]
    def name
      @name ||= metadata.attributes['Name'].value
    end

    # Returns a hash of EntitySet names and their respective EntityTypes.
    # @return [Hash<String, String>]
    def entity_sets
      @entity_sets ||= metadata.xpath('//EntitySet').map do |entity|
        [
          entity.attributes['Name'].value,
          entity.attributes['EntityType'].value
        ]
      end.to_h
    end

    # Retrieves the EntitySet associated with a specific EntityType by name
    #
    # @param entity_set_name [to_s] the name of the EntitySet desired
    # @return [FrOData::EntitySet] an FrOData::EntitySet to query
    def [](entity_set_name)
      xpath_query = "//EntitySet[@Name='#{entity_set_name}']"
      entity_set_node = metadata.xpath(xpath_query).first
      raise ArgumentError, "Unknown Entity Set: #{entity_set_name}" if entity_set_node.nil?
      entity_type = entity_set_node.attributes['EntityType'].value
      FrOData::EntitySet.new(
        name: entity_set_name,
        namespace: namespace,
        type: entity_type,
        service_name: service.name,
        container: name
      )
    end

    def singletons
      # TODO return singletons exposed by this EntityContainer
    end

    def actions
      # TODO return action imports exposed by this EntityContainer
    end

    def functions
      # TODO return function imports exposed by this EntityContainer
    end
  end
end
