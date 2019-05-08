module Frodo
  # An Frodo::Entity represents a single record returned by the service. All
  # Entities have a type and belong to a specific namespace. They are written
  # back to the service via the EntitySet they came from. Frodo::Entity
  # instances should not be instantiated directly; instead, they should either
  # be read or instantiated from their respective Frodo::EntitySet.
  class Entity
    # The Entity type name
    attr_reader :type
    # The Frodo::Service's identifying name
    attr_reader :service_name
    # The entity set this entity belongs to
    attr_reader :entity_set
    # List of errors on entity
    attr_reader :errors

    PROPERTY_NOT_LOADED = :not_loaded

    XML_NAMESPACES = {
      'xmlns'           => 'http://www.w3.org/2005/Atom',
      'xmlns:data'      => 'http://docs.oasis-open.org/odata/ns/data',
      'xmlns:metadata'  => 'http://docs.oasis-open.org/odata/ns/metadata',
      'xmlns:georss'    => 'http://www.georss.org/georss',
      'xmlns:gml'       => 'http://www.opengis.net/gml',
    }.freeze

    # Initializes a bare Entity
    # @param options [Hash]
    def initialize(options = {})
      @id = options[:id]
      @type = options[:type]
      @service_name = options[:service_name]
      @entity_set = options[:entity_set]
      @context = options[:context]
      @links = options[:links]
      @errors = []
    end

    def namespace
      @namespace ||= type.rpartition('.').first
    end

    # Returns name of Entity from Service specified type.
    # @return [String]
    def name
      @name ||= type.split('.').last
    end

    # Returns context URL for this entity
    # @return [String]
    def context
      @context ||= context_url
    end

    # Get property value
    # @param property_name [to_s]
    # @return [*]
    def [](property_name)
      if get_property(property_name).is_a?(::Frodo::Properties::Complex)
        get_property(property_name)
      else
        get_property(property_name).value
      end
    end

    # Set property value
    # @param property_name [to_s]
    # @param value [*]
    def []=(property_name, value)
      get_property(property_name).value = value
    end

    def get_property(property_name)
      prop_name = property_name.to_s
      # Property is lazy loaded
      if properties_xml_value.has_key?(prop_name)
        property = instantiate_property(prop_name, properties_xml_value[prop_name])
        set_property(prop_name, property.dup)
        properties_xml_value.delete(prop_name)
      end

      if properties.has_key? prop_name
        properties[prop_name]
      elsif navigation_properties.has_key? prop_name
        navigation_properties[prop_name]
      else
        raise ArgumentError, "Unknown property: #{property_name}"
      end
    end

    # strip inline annotations from property names and return separately
    def parse_annotations_from_property_name(property_name)
      prop_name, annotation = property_name.to_s.split('@', 2)
      return prop_name, annotation
    end

    def property_names
      [
        @properties_xml_value.andand.keys,
        @properties.andand.keys
      ].compact.flatten
    end

    def navigation_property_names
      navigation_properties.keys
    end

    def navigation_properties
      @navigation_properties ||= links.keys.map do |nav_name|
        [
          nav_name,
          Frodo::NavigationProperty::Proxy.new(self, nav_name)
        ]
      end.to_h
    end

    # Links to other Frodo entitites
    # @return [Hash]
    def links
      @links ||= schema.navigation_properties[name].map do |nav_name, details|
        [
          nav_name,
          { type: details.nav_type, href: "#{id}/#{nav_name}" }
        ]
      end.to_h
    end

    # Create Entity with provided properties and options.
    # @param new_properties [Hash]
    # @param options [Hash]
    # @param [Frodo::Entity]
    def self.with_properties(new_properties = {}, options = {})
      entity = Frodo::Entity.new(options)
      entity.instance_eval do
        service.properties_for_entity(type).each do |property_name, instance|
          set_property(property_name, instance)
        end

        new_properties.each do |property_name, property_value|
          prop_name, annotation = parse_annotations_from_property_name(property_name)
          # TODO: Do something with the annotation?
          self[prop_name] = property_value
        end
      end
      entity
    end

    # Create Entity from JSON document with provided options.
    # @param json [Hash|to_s]
    # @param options [Hash]
    # @return [Frodo::Entity]
    def self.from_json(json, options = {})
      return nil if json.nil?
      json = JSON.parse(json.to_s) unless json.is_a?(Hash)
      metadata = extract_metadata(json)
      options.merge!(context: metadata['@odata.context'])

      entity = with_properties(json, options)
      process_metadata(entity, metadata)
      entity
    end

    # Create Entity from XML document with provided options.
    # @param xml_doc [Nokogiri::XML]
    # @param options [Hash]
    # @return [Frodo::Entity]
    def self.from_xml(xml_doc, options = {})
      return nil if xml_doc.nil?
      entity = Frodo::Entity.new(options)
      process_properties(entity, xml_doc)
      process_links(entity, xml_doc)
      entity
    end

    # Converts Entity to its XML representation.
    # @return [String]
    def to_xml
      namespaces = XML_NAMESPACES.merge('xml:base' => service.service_url)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.entry(namespaces) do
          xml.category(term: type,
                       scheme: 'http://docs.oasis-open.org/odata/ns/scheme')
          xml.author { xml.name }

          xml.content(type: 'application/xml') do
            xml['metadata'].properties do
              property_names.each do |name|
                next if name == primary_key
                get_property(name).to_xml(xml)
              end
            end
          end
        end
      end
      builder.to_xml
    end

    # Converts Entity to its JSON representation.
    # @return [String]
    def to_json
      # TODO: add @odata.context
      to_hash.to_json
    end

    # Converts Entity to a hash.
    # @return [Hash]
    def to_hash
      property_names.map do |name|
        [name, get_property(name).json_value]
      end.to_h
    end

    # Returns the canonical URL for this entity
    # @return [String]
    def id
      @id ||= lambda {
        entity_set = self.entity_set.andand.name
        entity_set ||= context.split('#').last.split('/').first
        "#{entity_set}(#{self[primary_key]})"
      }.call
    end

    # Returns the primary key for the Entity.
    # @return [String]
    def primary_key
      schema.primary_key_for(name)
    end

    def is_new?
      self[primary_key].nil?
    end

    def any_errors?
      !errors.empty?
    end

    def service
      @service ||= Frodo::ServiceRegistry[service_name]
    end

    def schema
      @schema ||= service.schemas[namespace]
    end

    private

    def instantiate_property(property_name, value_xml)
      prop_type = schema.get_property_type(name, property_name)
      prop_type, value_type = prop_type.split(/\(|\)/)

      if prop_type == 'Collection'
        klass = ::Frodo::Properties::Collection
        options = { value_type: value_type }
      else
        klass = ::Frodo::PropertyRegistry[prop_type]
        options = {}
      end

      if klass.nil?
        raise RuntimeError, "Unknown property type: #{prop_type}"
      else
        klass.from_xml(value_xml, options.merge(service: service))
      end
    end

    def properties
      @properties ||= {}
    end

    def properties_xml_value
      @properties_xml_value ||= {}
    end

    # Computes the entity's canonical context URL
    def context_url
      "#{service.service_url}/$metadata##{entity_set.name}/$entity"
    end

    def set_property(name, property)
      properties[name.to_s] = property
    end

    # Instantiating properties takes time, so we can lazy load properties by passing xml_value and lookup when needed
    def set_property_lazy_load(name, xml_value )
      properties_xml_value[name.to_s] = xml_value
    end

    def self.process_properties(entity, xml_doc)
      entity.instance_eval do
        unless instance_variable_get(:@context)
          context = xml_doc.xpath('/entry').first.andand['context']
          instance_variable_set(:@context, context)
        end

        xml_doc.xpath('./content/properties/*').each do |property_xml|
          # Doing lazy loading here because instantiating each object takes a long time
          set_property_lazy_load(property_xml.name, property_xml)
        end
      end
    end

    def self.process_links(entity, xml_doc)
      entity.instance_eval do
        new_links = instance_variable_get(:@links) || {}
        schema.navigation_properties[name].each do |nav_name, details|
          p nav_name
          xml_doc.xpath("./link[@title='#{nav_name}']").each do |node|
            next if node.attributes['type'].nil?
            next unless node.attributes['type'].value =~ /^application\/atom\+xml;type=(feed|entry)$/i
            link_type = node.attributes['type'].value =~ /type=entry$/i ? :entity : :collection
            new_links[nav_name] = {
              type: link_type,
              href: node.attributes['href'].value
            }
          end
        end
        instance_variable_set(:@links, new_links)
      end
    end

    def self.extract_metadata(json)
      metadata = json.select { |key, val| key =~ /@odata/ }
      json.delete_if { |key, val| key =~ /@odata/ }
      metadata
    end

    def self.process_metadata(entity, metadata)
      entity.instance_eval do
        new_links = instance_variable_get(:@links) || {}
        schema.navigation_properties[name].each do |nav_name, details|
          href = metadata["#{nav_name}@odata.navigationLink"]
          next if href.nil?
          new_links[nav_name] = {
            type: details.nav_type,
            href: href
          }
        end
        instance_variable_set(:@links, new_links) unless new_links.empty?
      end
    end
  end
end
