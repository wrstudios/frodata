module Frodo
  module Properties
    # Abstract base class for Frodo ComplexTypes
    # @see [Frodo::Schema::ComplexType]
    class Complex < Frodo::Property
      def initialize(name, value, options = {})
        super(name, value, options)
        init_properties
      end

      # Returns the property value, properly typecast
      # @return [Hash, nil]
      def value
        if allows_nil? && properties.values.all?(&:nil?)
          nil
        else
          Hash[properties.map { |key, value| [key, value.value] }]
        end
      end

      # Sets the property value
      # @params new_value [Hash]
      def value=(new_value)
        validate(new_value)
        if new_value.nil?
          property_names.each { |name| self[name] = nil }
        else
          property_names.each { |name| self[name] = new_value[name] }
        end
      end

      # Returns a list of this ComplexType's property names.
      # @return [Array<String>]
      def property_names
        @property_names ||= properties.keys
      end

      # Returns the value of the requested property.
      # @param property_name [to_s]
      # @return [*]
      def [](property_name)
        properties[property_name.to_s].value
      end

      # Sets the value of the named property.
      # @param property_name [to_s]
      # @param value [*]
      # @return [*]
      def []=(property_name, value)
        properties[property_name.to_s].value = value
      end

      # Returns the XML representation of the property to the supplied XML
      # builder.
      # @param xml_builder [Nokogiri::XML::Builder]
      def to_xml(xml_builder)
        attributes = {
            'metadata:type' => type,
        }

        xml_builder['data'].send(name.to_sym, attributes) do
          properties.each do |name, property|
            property.to_xml(xml_builder)
          end
        end
      end

      # Creates a new property instance from an XML element
      # @param property_xml [Nokogiri::XML::Element]
      # @param options [Hash]
      # @return [Frodo::Property]
      def self.from_xml(property_xml, options = {})
        nodes = property_xml.element_children
        props = Hash[nodes.map { |el| [el.name, el.content] }]
        new(property_xml.name, props.to_json, options)
      end

      private

      def complex_type
        raise NotImplementedError, 'Subclass must override'
      end

      def properties
        @properties
      end

      def init_properties
        @properties = complex_type.send(:collect_properties)
        set_properties(JSON.parse(@value)) unless @value.nil?
      end

      def set_properties(new_properties)
        property_names.each do |prop_name|
          self[prop_name] = new_properties[prop_name]
        end
      end

      def validate(value)
        return if value.nil? && allows_nil?
        raise ArgumentError, 'Value must be a Hash' unless value.is_a?(Hash)
        value.keys.each do |name|
          unless property_names.include?(name) || name =~ /@odata/
            raise ArgumentError, "Invalid property #{name}"
          end
        end
      end

      def validate_options(options)
        raise ArgumentError, 'Type is required' unless options[:type]
      end
    end
  end
end
