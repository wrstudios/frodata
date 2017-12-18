module OData
  class NavigationProperty
    attr_reader :name, :type, :nullable, :partner

    def initialize(options)
      @name     = options[:name]
      @type     = options[:type]
      @nullable = options[:nullable] || false
      @partner  = options[:partner]
    end

    def self.build(nav_property_xml)
      options = nav_property_xml.attributes.map do |name, attr|
        [name.downcase.to_sym, attr.value]
      end.to_h
      new(options)
    end
  end
end
