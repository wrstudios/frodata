module OData4
  class Service
    class Response
      module XML
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
          response_xml.xpath('//error/message').first.andand.text
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
