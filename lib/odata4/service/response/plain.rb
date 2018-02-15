module OData4
  class Service
    class Response
      module Plain
        def process_results(&block)
          find_entities.each(&block)
        end

        def next_page
          raise NotImplementedError, 'Not available'
        end

        def next_page_url
          raise NotImplementedError, 'Not available'
        end

        def error_message
          response.body
        end

        private

        # Find entity entries in a response set
        #
        # @return [Array]
        def find_entities
          []
        end
      end
    end
  end
end
