module OData4
  class Query
    class Criteria
      module StringFunctions
        # Sets up a `contains` function criterium.
        # @param str [to_s]
        # @return [self]
        def contains(str)
          set_function_and_argument(:contains, str)
        end

        # Sets up a `startswith` function criterium.
        # @param str [to_s]
        # @return [self]
        def startswith(str)
          set_function_and_argument(:startswith, str)
        end

        # Sets up a `endswith` function criterium.
        # @param str [to_s]
        # @return [self]
        def endswith(str)
          set_function_and_argument(:endswith, str)
        end

        # Applies the `tolower` function to the property.
        # @return [self]
        def tolower
          set_function_and_argument(:tolower, nil)
        end

        # Applies the `toupper` function to the property.
        # @return [self]
        def toupper
          set_function_and_argument(:toupper, nil)
        end
      end
    end
  end
end
