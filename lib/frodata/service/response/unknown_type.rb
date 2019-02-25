module FrOData
    class Service
      class Response
        module UnknownType
          def parse_entity(entity_json, entity_options)
            response.body
          end

          def next_page
          end

          def next_page_url
          end

          def error_message
            response.body
          end

          def parsed_body
            response.body
          end
        end
      end
    end
  end
