module FrOData
  class Query
    class Criteria
      module LambdaOperators
        # Applies the `any` lambda operator to the given property
        # @param property [to_s]
        # @return [self]
        def any(property)
          set_function_and_argument(:any, property)
        end

        # Applies the `any` lambda operator to the given property
        # @param property [to_s]
        # @return [self]
        def all(property)
          set_function_and_argument(:all, property)
        end

        private

        def lambda_operator?
          [:any, :all].include?(function)
        end
      end
    end
  end
end
