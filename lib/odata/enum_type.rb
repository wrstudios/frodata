require 'odata/enum_type/property'

module OData
  # Enumeration types are nominal types that represent a series of related values.
  # Enumeration types expose these related values as members of the enumeration.
  class EnumType
    # Creates a new EnumType based on the supplied options.
    # @param type_xml [Nokogiri::XML::Element]
    # @param service [OData::Service]
    # @return [self]
    def initialize(type_definition, service)
      @type_definition = type_definition
      @service         = service
    end

    # The name of the EnumType
    # @return [String]
    def name
      @name ||= type_definition.attributes['Name'].value
    end

    # Returns the namespaced type for the EnumType.
    # @return [String]
    def type
      "#{namespace}.#{name}"
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

    # Returns the property class that implements this `EnumType`.
    # @return [Class < OData::EnumType::Property]
    def property_class
      @property_class ||= lambda { |type, members|
        klass = Class.new ::OData::EnumType::Property
        klass.send(:define_method, :type) { type }
        klass.send(:define_method, :members) { members }
        klass
      }.call(type, members)
    end

    # Returns the value of the requested member.
    # @param member_name [to_s]
    # @return [*]
    def [](member_name)
      members[member_name.to_s]
    end

    private

    def service
      @service
    end

    def type_definition
      @type_definition
    end

    def collect_members
      Hash[type_definition.xpath('./Member').map.with_index do |member_xml, index|
        member_name  = member_xml.attributes['Name'].value
        member_value = member_xml.attributes['Value'].andand.value.to_i
        [member_name, member_value || index]
      end]
    end
  end
end
