require 'odata/enum_type/property'

module OData
  # Enumeration types are nominal types that represent a series of related values.
  # Enumeration types expose these related values as members of the enumeration.
  class EnumType
    # The name of the EnumType
    attr_reader :name

    # Creates a new EnumType based on the supplied options.
    # @param options [Hash]
    # @return [self]
    def initialize(options = {})
      validate_options(options)

      @name = options[:name].to_s
      @service = options[:service]

      collect_members
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
      @members
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

    def validate_options(options)
      raise ArgumentError, 'Name is required' unless options[:name]
      raise ArgumentError, 'Service is required' unless options[:service]
      raise ArgumentError, 'Not an EnumType' unless options[:service].enum_types.include? options[:name]
    end

    def collect_members
      @members = service.members_for_enum_type(name)
    end
  end
end
