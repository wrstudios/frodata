module OData
  # Encapsulates the basic details and functionality needed to interact with an
  # OData service.
  class Service
    # The OData Service's URL
    attr_reader :service_url
    # Options to pass around
    attr_reader :options

    HTTP_TIMEOUT = 20

    METADATA_TIMEOUTS = [20, 60]

    MIME_TYPES = {
      atom:  'application/atom+xml',
      json:  'application/json',
      plain: 'text/plain'
    }

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
    # @param options [Hash] options to pass to the service
    # @return [OData::Service] an instance of the service
    def initialize(service_url, options = {})
      @service_url = service_url
      @options = default_options.merge(options)
      OData::ServiceRegistry.add(self)
      register_custom_types
    end

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
    # @param options [Hash] options to pass to the service
    # @return [OData::Service] an instance of the service
    def self.open(service_url, options = {})
      Service.new(service_url, options)
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

    # Returns a list of entities exposed by the service
    def entity_types
      @entity_types ||= metadata.xpath('//EntityType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns a hash of EntitySet names keyed to their respective EntityType name
    def entity_sets
      @entity_sets ||= metadata.xpath('//EntityContainer/EntitySet').collect {|entity|
        [
          entity.attributes['EntityType'].value.gsub("#{namespace}.", ''),
          entity.attributes['Name'].value
        ]
      }.to_h
    end

    # Returns a list of ComplexTypes used by the service
    # @return [Hash<String, OData::ComplexType>]
    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').map do |entity|
        [
          entity.attributes['Name'].value,
          ::OData::ComplexType.new(entity, self)
        ]
      end.to_h
    end

    # Returns a list of EnumTypes used by the service
    # @return [Hash<String, OData::EnumType>]
    def enum_types
      @enum_types ||= metadata.xpath('//EnumType').map do |entity|
        [
          entity.attributes['Name'].value,
          ::OData::EnumType.new(entity, self)
        ]
      end.to_h
    end

    # Returns a hash for finding an association through an entity type's defined
    # NavigationProperty elements.
    # @return [Hash<Hash<OData::Association>>]
    def navigation_properties
      @navigation_properties ||= metadata.xpath('//EntityType').collect do |entity_type_def|
        entity_type_name = entity_type_def.attributes['Name'].value
        [
            entity_type_name,
            entity_type_def.xpath('./NavigationProperty').collect do |nav_property_def|
              [
                  nav_property_def.attributes['Name'].value,
                  ::OData::NavigationProperty.build(nav_property_def)
              ]
            end.to_h
        ]
      end.to_h
    end

    # Returns the namespace defined on the service's schema
    def namespace
      @namespace ||= metadata.xpath('//Schema').first.attributes['Namespace'].value
    end

    # Returns a more compact inspection of the service object
    def inspect
      "#<#{self.class.name}:#{self.object_id} name='#{name}' service_url='#{self.service_url}'>"
    end

    # Retrieves the EntitySet associated with a specific EntityType by name
    #
    # @param entity_set_name [to_s] the name of the EntitySet desired
    # @return [OData::EntitySet] an OData::EntitySet to query
    def [](entity_set_name)
      xpath_query = "//EntityContainer/EntitySet[@Name='#{entity_set_name}']"
      entity_set_node = metadata.xpath(xpath_query).first
      raise ArgumentError, "Unknown Entity Set: #{entity_set_name}" if entity_set_node.nil?
      container_name = entity_set_node.parent.attributes['Name'].value
      entity_type_name = entity_set_node.attributes['EntityType'].value.gsub(/#{namespace}\./, '')
      OData::EntitySet.new(name: entity_set_name,
                           namespace: namespace,
                           type: entity_type_name.to_s,
                           service_name: name,
                           container: container_name)
    end

    # Execute a request against the service
    #
    # @param url_chunk [to_s] string to append to service url
    # @param additional_options [Hash] options to pass to Typhoeus
    # @return [Typhoeus::Response]
    def execute(url_chunk, additional_options = {})
      logger.info "Requesting #{url_chunk}..."
      accept = content_type(additional_options.delete(:format) || :auto)
      accept_header = {'Accept' => accept }

      request_options = options[:typhoeus]
        .merge({ method: :get })
        .merge(additional_options)

      # Don't overwrite Accept header if already present
      unless request_options[:headers]['Accept']
        request_options[:headers] = request_options[:headers].merge(accept_header)
      end

      request = ::Typhoeus::Request.new(
        URI.escape("#{service_url}/#{url_chunk}"), request_options
      )
      request.run

      response = request.response
      # logger.debug(response.headers)
      # logger.debug(response.body)
      validate_response(response)
      response
    end

    # Find a specific node in the given result set
    #
    # @param results [Typhoeus::Response]
    # @return [Nokogiri::XML::Element]
    def find_node(results, node_name)
      document = ::Nokogiri::XML(results.body)
      document.remove_namespaces!
      document.xpath("//#{node_name}").first
    end

    # Find entity entries in a result set
    #
    # @param results [Typhoeus::Response]
    # @return [Nokogiri::XML::NodeSet]
    def find_entities(results)
      document = ::Nokogiri::XML(results.body)
      document.remove_namespaces!
      document.xpath('//entry')
    end

    # Get the property type for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @param property_name [to_s] the property name needed
    # @return [String] the name of the property's type
    def get_property_type(entity_name, property_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@Name='#{property_name}']").first.attributes['Type'].value
    end

    # Get the property used as the title for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @return [String] the name of the property used as the entity title
    def get_title_property_name(entity_name)
      node = metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@FC_TargetPath='SyndicationTitle']").first
      node.nil? ? nil : node.attributes['Name'].value
    end

    # Get the property used as the summary for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @return [String] the name of the property used as the entity summary
    def get_summary_property_name(entity_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@FC_TargetPath='SyndicationSummary']").first.attributes['Name'].value
    rescue NoMethodError
      nil
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

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    def logger=(custom_logger)
      @logger = custom_logger
    end

    private

    def default_options
      {
          typhoeus: {
              headers: { 'OData-Version' => '4.0' },
              timeout: HTTP_TIMEOUT
          }
      }
    end

    def content_type(format)
      if format == :auto
        MIME_TYPES.values.join(',')
      elsif MIME_TYPES.has_key? format
        MIME_TYPES[format]
      else
        raise ArgumentError, "Unknown format '#{format}'"
      end
    end

    def metadata
      @metadata ||= lambda { read_metadata }.call
    end

    def read_metadata
      response = nil
      # From file, good for debugging
      if options[:metadata_file]
        data = File.read(options[:metadata_file])
        ::Nokogiri::XML(data).remove_namespaces!
      else # From a URL
        METADATA_TIMEOUTS.each do |timeout|
          response = ::Typhoeus::Request.get(URI.escape(metadata_url),
                                             options[:typhoeus].merge(timeout: timeout))
          break unless response.timed_out?
        end
        raise "Metadata Timeout" if response.timed_out?
        validate_response(response)
        ::Nokogiri::XML(response.body).remove_namespaces!
      end
    end

    def validate_response(response)
      raise "Bad Request. #{error_message(response)}" if response.code == 400
      raise "Access Denied" if response.code == 401
      raise "Forbidden" if response.code == 403
      raise "Not Found" if [0,404].include?(response.code)
      raise "Method Not Allowed" if response.code == 405
      raise "Not Acceptable" if response.code == 406
      raise "Request Entity Too Large" if response.code == 413
      raise "Internal Server Error" if response.code == 500
      raise "Service Unavailable" if response.code == 503
    end

    def error_message(response)
      OData::Query::Result.new(nil, response).error_message
    end

    def process_property_from_xml(property_xml)
      property_name = property_xml.attributes['Name'].value
      value_type = property_xml.attributes['Type'].value
      property_options = {}

      klass = ::OData::PropertyRegistry[value_type]

      if klass.nil?
        raise RuntimeError, "Unknown property type: #{value_type}"
      else
        property_options[:allows_nil] = false if property_xml.attributes['Nullable'] == 'false'
        property = klass.new(property_name, nil, property_options)
      end

      return [property_name, property]
    end

    def register_custom_types
      complex_types.each do |name, type|
        ::OData::PropertyRegistry.add(type.type, type.property_class)
      end

      enum_types.each do |name, type|
        ::OData::PropertyRegistry.add(type.type, type.property_class)
      end
    end
  end
end
