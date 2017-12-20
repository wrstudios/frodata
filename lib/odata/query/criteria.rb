require 'odata/query/criteria/comparison_operators'
require 'odata/query/criteria/string_functions'

module OData
  class Query
    # Represents a discreet criteria within an OData::Query. Should not,
    # normally, be instantiated directly.
    class Criteria
      # The property name that is the target of the criteria.
      attr_reader :property
      # The operator of the criteria.
      attr_reader :operator
      # The value of the criteria.
      attr_reader :value
      # A function to apply to the property.
      attr_reader :function
      # An optional argument to the function.
      attr_reader :argument

      # Initializes a new criteria with provided options.
      # @param options [Hash]
      def initialize(options = {})
        @property = options[:property]
        @operator = options[:operator]
        @function = options[:function]
        @argument = options[:argument]
        @value    = options[:value]
      end

      include ComparisonOperators
      include StringFunctions

      # Returns criteria as query-ready string.
      def to_s
        if function && operator
          "#{function}(#{property_name}) #{operator} #{url_value(value)}"
        elsif function
          "#{function}(#{property_name},#{url_value(argument)})"
        else
          "#{property_name} #{operator} #{url_value(value)}"
        end
      end

      private

      def property_name
        property.name
      rescue NoMethodError
        property.to_s
      end

      def url_value(value)
        property.value = value if property.respond_to?(:value)
        property.respond_to?(:url_value) ? property.url_value : value
      end

      def set_operator_and_value(operator, value)
        @operator = operator
        @value = value
        self
      end

      def set_function_and_argument(function, argument)
        @function = function
        @argument = argument
        self
      end
    end
  end
end
