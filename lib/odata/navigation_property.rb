module OData
  class NavigationProperty
    attr_reader :name, :type, :nullable, :partner

    def initialize(options)
      @name     = options[:name]
      @type     = options[:type]
      @nullable = options[:nullable]
      @partner  = options[:partner]
    end
  end
end
