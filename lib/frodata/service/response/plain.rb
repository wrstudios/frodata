module FrOData
  class Service
    class Response
      module Plain
        def parse_entity(entity_data, entity_options)
          raise NotImplementedError, 'Not Available'
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

        def parsed_body
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
