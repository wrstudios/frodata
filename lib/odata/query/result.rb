module OData
  class Query
    # Represents the results of executing a OData::Query.
    # @api private
    class Result
      include Enumerable

      attr_reader :query

      # Initialize a result with the query and the result.
      # @param query [OData::Query]
      # @param result [Typhoeus::Result]
      def initialize(query, result)
        @query      = query
        @result     = result
        check_result_type
      end

      # Provided for Enumerable functionality
      # @param block [block] a block to evaluate
      # @return [OData::Entity] each entity in turn for the query result
      def each(&block)
        unless empty?
          process_results(&block)
          until next_page.nil?
            # ensure query gets executed with the same options
            result = query.execute(next_page_url)
            process_results(&block)
          end
        end
      end

      # Checks whether the result set contains any results
      # @return [Boolean]
      def empty?
        @empty_result ||= find_entities.empty?
      end

      private

      attr_accessor :result

      def check_result_type
        # Dynamically extend instance with methods for
        # processing the current result type
        if is_atom_result?
          extend OData::Query::Result::Atom
        elsif is_json_result?
          extend OData::Query::Result::JSON
        elsif result.body.empty?
          # Some services (*cough* Microsoft *cough*) return
          # an empty response with no `Content-Type` header set.
          # We catch that here and bypass content type detection.
          @empty_result = true
        else
          raise ArgumentError, "Invalid result type '#{content_type}'"
        end
      end

      def is_atom_result?
        content_type =~ /#{Regexp.escape OData::Service::MIME_TYPES[:atom]}/
      end

      def is_json_result?
        content_type =~ /#{Regexp.escape OData::Service::MIME_TYPES[:json]}/
      end

      def content_type
        result.headers['Content-Type'] || ''
      end

      def service
        query.entity_set.service
      end

      def entity_options
        query.entity_set.entity_options
      end
    end
  end
end

require 'odata/query/result/atom'
require 'odata/query/result/json'
