module FrOData
  class Query
    class Criteria
      module DateFunctions
        # Applies the `year` function.
        # @return [self]
        def year
          set_function_and_argument(:year, nil)
        end

        # Applies the `month` function.
        # @return [self]
        def month
          set_function_and_argument(:month, nil)
        end

        # Applies the `day` function.
        # @return [self]
        def day
          set_function_and_argument(:day, nil)
        end

        # Applies the `hour` function.
        # @return [self]
        def hour
          set_function_and_argument(:hour, nil)
        end

        # Applies the `minute` function.
        # @return [self]
        def minute
          set_function_and_argument(:minute, nil)
        end

        # Applies the `second` function.
        # @return [self]
        def second
          set_function_and_argument(:second, nil)
        end

        # Applies the `fractionalseconds` function.
        # @return [self]
        def fractionalseconds
          set_function_and_argument(:fractionalseconds, nil)
        end

        # Applies the `date` function.
        # @return [self]
        def date
          set_function_and_argument(:date, nil)
        end

        # Applies the `time` function.
        # @return [self]
        def time
          set_function_and_argument(:time, nil)
        end
      end
    end
  end
end
