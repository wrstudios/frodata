module OData
  class NavigationProperty
    attr_reader :name, :type, :nullable, :partner

    def initialize(options)
      @name     = options[:name] or raise ArgumentError, 'Name is required'
      @type     = options[:type] or raise ArgumentError, 'Type is required'
      @nullable = options[:nullable] || true
      @partner  = options[:partner]
    end

    def nav_type
      type =~ /^Collection/ ? :collection : :entity
    end

    def self.build(nav_property_xml)
      options = nav_property_xml.attributes.map do |name, attr|
        [name.downcase.to_sym, attr.value]
      end.to_h
      new(options)
    end
  end
end
