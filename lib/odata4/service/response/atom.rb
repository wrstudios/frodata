module OData4
  class Service
    class Response
      module Atom
        def process_results(&block)
          find_entities.each do |entity_xml|
            entity = OData4::Entity.from_xml(entity_xml, entity_options)
            block_given? ? block.call(entity) : yield(entity)
          end
        end

        def next_page
          result_xml.xpath("/feed/link[@rel='next']").first
        end

        def next_page_url
          next_page.attributes['href'].value.gsub(service.service_url, '')
        end

        def error_message
          result_xml.xpath('//error/message').first.andand.text
        end

        private

        def result_xml
          @result_xml ||= ::Nokogiri::XML(response.body).remove_namespaces!
        end

        # Find entity entries in a result set
        #
        # @return [Nokogiri::XML::NodeSet]
        def find_entities
          result_xml.xpath('//entry')
        end
      end
    end
  end
end
