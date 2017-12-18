module OData
  class Query
    class Result
      # Represents the results of executing a OData::Query.
      # @api private
      module JSON
        def process_results(&block)
          find_entities.each do |entity_json|
            entity = OData::Entity.from_json(entity_json, entity_options)
            block_given? ? block.call(entity) : yield(entity)
          end
        end

        def next_page
          result_json['@odata.nextLink']
        end

        def next_page_url
          next_page.gsub(service.service_url, '')
        end

        private

        def result_json
          @result_json ||= ::JSON.parse(result.body)
        end

        def single_entity?
          result_json['@odata.context'] =~ /\$entity$/
        end

        def find_entities
          single_entity? ? [result_json] : result_json['value']
        end
      end
    end
  end
end
