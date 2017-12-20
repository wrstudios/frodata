module OData
  class Query
    class Criteria
      module ComparisonOperators
        # Sets up equality operator.
        # @param value [to_s]
        # @return [self]
        def eq(value)
          set_operator_and_value(:eq, value)
        end

        # Sets up non-equality operator.
        # @param value [to_s]
        # @return [self]
        def ne(value)
          set_operator_and_value(:ne, value)
        end

        # Sets up greater-than operator.
        # @param value [to_s]
        # @return [self]
        def gt(value)
          set_operator_and_value(:gt, value)
        end

        # Sets up greater-than-or-equal operator.
        # @param value [to_s]
        # @return [self]
        def ge(value)
          set_operator_and_value(:ge, value)
        end

        # Sets up less-than operator.
        # @param value [to_s]
        # @return [self]
        def lt(value)
          set_operator_and_value(:lt, value)
        end

        # Sets up less-than-or-equal operator.
        # @param value [to_s]
        # @return [self]
        def le(value)
          set_operator_and_value(:le, value)
        end
      end
    end
  end
end
