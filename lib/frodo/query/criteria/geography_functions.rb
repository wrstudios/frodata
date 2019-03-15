module Frodo
  class Query
    class Criteria
      module GeographyFunctions
        # Applies the `geo.distance` function.
        # @param to [to_s]
        # @return [self]
        def distance(to)
          set_function_and_argument(:'geo.distance', to)
        end

        # Applies the `geo.intersects` function.
        # @param what [to_s]
        # @return [self]
        def intersects(what)
          set_function_and_argument(:'geo.intersects', what)
        end
      end
    end
  end
end
