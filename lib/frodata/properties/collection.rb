module FrOData
  module Properties
    # Defines the Collection FrOData type.
    class Collection < FrOData::Property
      # Overriding default constructor to avoid converting
      # value to string.
      # TODO: Make this the default for all property types?
      def initialize(name, value, options = {})
        super(name, value, options)
        self.value = value
      end

      def value
        if @value.nil?
          nil
        else
          @value.map(&:value)
        end
      end

      def value=(value)
        if value.nil? && allows_nil?
          @value = nil
        elsif value.respond_to?(:map)
          @value = value.map.with_index do |element, index|
            type_class.new("#{name}[#{index}]", element)
          end
        else
          validation_error 'Value must be an array'
        end
      end

      def url_value
        '[' + @value.map(&:url_value).join(',') + ']'
      end

      def type
        "Collection(#{value_type})"
      end

      def value_type
        options[:value_type] || 'Edm.String'
      end

      def type_class
        FrOData::PropertyRegistry[value_type]
      end
    end
  end
end
