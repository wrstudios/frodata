module FrOData
  class Service
    class Response
      module XML
        def parse_entity(entity_data, entity_options)
          raise NotImplementedError, 'Not Available'
        end

        def next_page
          raise NotImplementedError, 'Not Available'
        end

        def next_page_url
          raise NotImplementedError, 'Not Available'
        end

        def error_message
          response_xml.xpath('//error/message').first.andand.text
        end

        def parsed_body
          response_xml
        end

        private

        def response_xml
          @response_xml ||= ::Nokogiri::XML(response.body).remove_namespaces!
        end

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
