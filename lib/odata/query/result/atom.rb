module OData
  class Query
    class Result
      # Represents the results of executing a OData::Query.
      # @api private
      module Atom
        def process_results(&block)
          find_entities.each do |entity_xml|
            entity = OData::Entity.from_xml(entity_xml, entity_options)
            block_given? ? block.call(entity) : yield(entity)
          end
        end

        def next_page
          result_xml.xpath("/feed/link[@rel='next']").first
        end

        def next_page_url
          next_page.attributes['href'].value.gsub(service.service_url, '')
        end

        private

        def result_xml
          @result_xml ||= ::Nokogiri::XML(result.body).remove_namespaces!
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
