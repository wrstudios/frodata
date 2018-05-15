require 'frodata/query/criteria/comparison_operators'
require 'frodata/query/criteria/string_functions'
require 'frodata/query/criteria/date_functions'
require 'frodata/query/criteria/geography_functions'
require 'frodata/query/criteria/lambda_operators'

module FrOData
  class Query
    # Represents a discreet criteria within an FrOData::Query. Should not,
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
      include DateFunctions
      include GeographyFunctions
      include LambdaOperators

      # Returns criteria as query-ready string.
      def to_s
        query = function ? function_expression : property_name

        if operator && !lambda_operator?
          "#{query} #{operator} #{url_value(value)}"
        else
          query
        end
      end

      private

      def property_name
        property.name
      rescue NoMethodError
        property.to_s
      end

      def function_expression
        return lambda_expression if lambda_operator?

        if argument
          "#{function}(#{property_name},#{url_value(argument)})"
        else
          "#{function}(#{property_name})"
        end
      end

      def lambda_expression
        "#{property_name}/#{function}(d:d/#{argument} #{operator} #{url_value(value)})"
      end

      def url_value(value)
        property.value = value
        property.url_value
      rescue
        value
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
