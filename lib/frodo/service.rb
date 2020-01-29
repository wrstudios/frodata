module Frodo
  # Encapsulates the basic details and functionality needed to interact with an
  # Frodo service.
  class Service
    # The Frodo Service's URL
    attr_reader :service_url
    # Service options
    attr_reader :options


    # Opens the service based on the requested URL and adds the service to
    # {Frodo::Registry}
    #
    # @param service_url [String]
    #   The URL to the Frodo service
    # @param options [Hash] options to pass to the service
    # @return [Frodo::Service] an instance of the service
    def initialize(service_url, options = {}, &block)
      @options = default_options.merge(options)
      @service_url = service_url

      Frodo::ServiceRegistry.add(self)
      register_custom_types if @options[:with_metadata]
    end

    # Returns user supplied name for service, or its URL
    # @return [String]
    def name
      @name ||= options[:name] || service_url
    end

    # Returns the service's metadata URL.
    # @return [String]
    def metadata_url
      "#{service_url}/$metadata"
    end

    # Returns the service's metadata definition.
    # @return [Nokogiri::XML]
    def metadata
      @metadata ||= lambda { read_metadata }.call
    end

    # Returns all of the service's schemas.
    # @return Hash<String, Frodo::Schema>
    def schemas
      @schemas ||= metadata.xpath('//Schema').map do |schema_xml|
        [
          schema_xml.attributes['Namespace'].value,
          Schema.new(schema_xml, self, options[:navigation_properties])
        ]
      end.to_h
    end

    # Returns the service's EntityContainer (singleton)
    # @return Frodo::EntityContainer
    def entity_container
      @entity_container ||= EntityContainer.new(self)
    end

    # Returns a hash of EntitySet names and their respective EntityType names
    # @return Hash<String, String>
    def entity_sets
      entity_container.entity_sets
    end

    # Retrieves the EntitySet associated with a specific EntityType by name
    #
    # @param entity_set_name [to_s] the name of the EntitySet desired
    # @return [Frodo::EntitySet] an Frodo::EntitySet to query
    def [](entity_set_name)
      if with_metadata?
        entity_container[entity_set_name]
      else
        EntitySet.new(name: entity_set_name)
      end
    end

    # Returns the default namespace, that is, the namespace of the schema
    # that contains the service's EntityContainer.
    # @return [String]
    def namespace
      entity_container.namespace
    end

    # Returns a list of `EntityType`s exposed by the service
    # @return Array<String>
    def entity_types
      @entity_types ||= schemas.map do |namespace, schema|
        schema.entity_types.map do |entity_type|
          "#{namespace}.#{entity_type}"
        end
      end.flatten
    end

    # Returns a list of `ComplexType`s used by the service.
    # @return [Hash<String, Frodo::Schema::ComplexType>]
    def complex_types
      @complex_types ||= schemas.map do |namespace, schema|
        schema_hash = {}
        schema.complex_types.map do |name, complex_type|
          schema_hash["#{namespace}.#{name}"] = complex_type
          if schema.alias
            schema_hash["#{schema.alias}.#{name}"] = complex_type
          end
        end
        schema_hash
      end.reduce({}, :merge)
    end

    # Returns a list of `EnumType`s used by the service
    # @return [Hash<String, Frodo::Schema::EnumType>]
    def enum_types
      @enum_types ||= schemas.map do |namespace, schema|
        schema.enum_types.map do |name, enum_type|
          [ "#{namespace}.#{name}", enum_type ]
        end.to_h
      end.reduce({}, :merge)
    end

    # Returns a more compact inspection of the service object
    def inspect
      "#<#{self.class.name}:#{self.object_id} name='#{name}' service_url='#{self.service_url}'>"
    end

    # Get the property type for an entity from metadata.
    #
    # @param entity_name [to_s] the fully qualified entity name
    # @param property_name [to_s] the property name needed
    # @return [String] the name of the property's type
    def get_property_type(entity_name, property_name)
      namespace, _, entity_name = entity_name.rpartition('.')
      raise ArgumentError, 'Namespace missing' if namespace.nil? || namespace.empty?
      schemas[namespace].get_property_type(entity_name, property_name)
    end

    # Get the primary key for the supplied Entity.
    #
    # @param entity_name [to_s] The fully qualified entity name
    # @return [String]
    def primary_key_for(entity_name)
      namespace, _, entity_name = entity_name.rpartition('.')
      raise ArgumentError, 'Namespace missing' if namespace.nil? || namespace.empty?
      schemas[namespace].primary_key_for(entity_name)
    end

    # Get the list of properties and their various options for the supplied
    # Entity name.
    # @param entity_name [to_s]
    # @return [Hash]
    # @api private
    def properties_for_entity(entity_name)
      namespace, _, entity_name = entity_name.rpartition('.')
      raise ArgumentError, 'Namespace missing' if namespace.nil? || namespace.empty?
      schemas[namespace].properties_for_entity(entity_name)
    end

    # Returns the logger instance used by the service.
    # When Ruby on Rails has been detected, the service will
    # use `Rails.logger`. The log level will NOT be changed.
    #
    # When no Rails has been detected, a default logger will
    # be used that logs to STDOUT with the log level supplied
    # via options, or the default log level if none was given.
    # @return [Logger]
    def logger
      @logger ||= options[:logger] || if defined?(Rails)
        Rails.logger
      else
        default_logger
      end
    end

    def with_metadata?
      !@options.key?(:with_metadata) || @options[:with_metadata]
    end

    private

    def default_options
      {
        strict: true, # strict property validation
        with_metadata: true
      }
    end

    def default_logger
      Frodo.configuration.logger if Frodo.log?
    end

    def read_metadata
      # From file, good for debugging
      if options[:metadata_file]
        data = File.read(options[:metadata_file])
        ::Nokogiri::XML(data).remove_namespaces!
      elsif options[:metadata_document]
        data = options[:metadata_document]
        ::Nokogiri::XML(data).remove_namespaces!
      end
    end

    def register_custom_types
      complex_types.each do |name, type|
        ::Frodo::PropertyRegistry.add(name, type.property_class)
      end

      enum_types.each do |name, type|
        ::Frodo::PropertyRegistry.add(name, type.property_class)
      end
    end
  end
end
