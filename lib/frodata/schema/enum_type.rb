module FrOData
  class Schema
    # Enumeration types are nominal types that represent a series of related values.
    # Enumeration types expose these related values as members of the enumeration.
    class EnumType
      # Creates a new EnumType based on the supplied options.
      # @param type_xml [Nokogiri::XML::Element]
      # @param service [FrOData::Service]
      # @return [self]
      def initialize(type_definition, schema)
        @type_definition = type_definition
        @schema          = schema
      end

      # The name of the EnumType
      # @return [String]
      def name
        options['Name']
      end

      # Returns the namespaced type for the EnumType.
      # @return [String]
      def type
        "#{namespace}.#{name}"
      end

      # Whether this EnumType supports setting multiple values.
      # @return [Boolean]
      def is_flags?
        options['IsFlags'] == 'true'
      end

      # The underlying type of this EnumType.
      # @return [String]
      def underlying_type
        options['UnderlyingType'] || 'Edm.Int32'
      end

      # Returns the namespace this EnumType belongs to.
      # @return [String]
      def namespace
        @namespace ||= service.namespace
      end

      # Returns the members of this EnumType and their values.
      # @return [Hash]
      def members
        @members ||= collect_members
        end

      def annotated_members
        @annotated_members ||= collect_annotated_members
      end

      # Returns the property class that implements this `EnumType`.
      # @return [Class < FrOData::Properties::Enum]
      def property_class
        @property_class ||= lambda { |type, members, annotated_members, is_flags|
          klass = Class.new ::FrOData::Properties::Enum
          klass.send(:define_method, :type) { type }
          klass.send(:define_method, :members) { members }
          klass.send(:define_method, :annotated_members) { annotated_members }
          klass.send(:define_method, :is_flags?) { is_flags }
          klass
        }.call(type, members, annotated_members, is_flags?)
      end

      # Returns the value of the requested member.
      # @param member_name [to_s]
      # @return [*]
      def [](member_name)
        members.invert[member_name.to_s]
      end

      private

      def service
        @schema.service
      end

      def type_definition
        @type_definition
      end

      def options
        @options = type_definition.attributes.map do |name, attr|
          [name, attr.value]
        end.to_h
      end

      def collect_members
        Hash[type_definition.xpath('./Member').map.with_index do |member_xml, index|
          member_name  = member_xml.attributes['Name'].value
          member_value = member_xml.attributes['Value'].andand.value.andand.to_i
          [member_value || index, member_name]
        end]
        end

      def collect_annotated_members
        Hash[type_definition.xpath('./Member').map.with_index do |member_xml, index|
          member_name  = member_xml.attributes['Name'].value
          member_value = member_xml.attributes['Value'].andand.value.andand.to_i
          annotation = nil
          if member_xml.element_children.count > 0
            annotation = member_xml.element_children.last.attribute('String').value
          end
          [member_value || index, {name: member_name, annotation: annotation}]
        end]
      end
    end
  end
end
