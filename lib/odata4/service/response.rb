require 'odata4/service/response/atom'
require 'odata4/service/response/json'
require 'odata4/service/response/plain'
require 'odata4/service/response/xml'

module OData4
  class Service
    # The result of executing a OData4::Service::Request.
    class Response
      include Enumerable

      # The service that generated this response
      attr_reader :service
      # The underlying (raw) response
      attr_reader :response
      # The query that generated the response (optional)
      attr_reader :query

      # Create a new response given a service and a raw response.
      # @param service [OData4::Service]
      # @param response [Typhoeus::Result]
      def initialize(service, response, query = nil)
        @service  = service
        @response = response
        @query    = query
        check_content_type
        validate_response
      end

      # Returns the HTTP status code.
      def status
        response.code
      end

      # Whether the request was successful.
      def success?
        200 <= status && status < 300
      end

      # Returns the content type of the resonse.
      def content_type
        response.headers['Content-Type'] || ''
      end

      def is_atom?
        content_type =~ /#{Regexp.escape OData4::Service::MIME_TYPES[:atom]}/
      end

      def is_json?
        content_type =~ /#{Regexp.escape OData4::Service::MIME_TYPES[:json]}/
      end

      def is_plain?
        content_type =~ /#{Regexp.escape OData4::Service::MIME_TYPES[:plain]}/
      end

      def is_xml?
        content_type =~ /#{Regexp.escape OData4::Service::MIME_TYPES[:xml]}/
      end

      # Whether the response contained any entities.
      # @return [Boolean]
      def empty?
        @empty ||= find_entities.empty?
      end

      # Whether the response failed due to a timeout
      def timed_out?
        response.timed_out?
      end

      # Provided for Enumerable functionality
      # @param block [block] a block to evaluate
      # @return [OData4::Entity] each entity in turn for the query result
      def each(&block)
        unless empty?
          process_results(&block)
          until next_page.nil?
            # ensure query gets executed with the same options
            result = query.execute(URI.decode next_page_url)
            process_results(&block)
          end
        end
      end

      # Returns the response body.
      def body
        response.body
      end

      private

      def entity_options
        if query
          query.entity_set.entity_options
        else
          {
            service_name: service.name,
          }
        end
      end

      def logger
        service.logger
      end

      def check_content_type
        # Dynamically extend instance with methods for
        # processing the current result type
        if is_atom?
          extend OData4::Service::Response::Atom
        elsif is_json?
          extend OData4::Service::Response::JSON
        elsif is_xml?
          extend OData4::Service::Response::XML
        elsif is_plain?
          extend OData4::Service::Response::Plain
        elsif response.body.empty?
          # Some services (*cough* Microsoft *cough*) return
          # an empty response with no `Content-Type` header set.
          # We catch that here and bypass content type detection.
          @empty = true
        else
          raise ArgumentError, "Invalid response type '#{content_type}'"
        end
      end

      def validate_response
        logger.debug <<-EOS
          [OData4: #{service.name}] Received response:
            Headers: #{response.headers}
            Body: #{response.body}
        EOS
        raise "Bad Request. #{error_message(response)}" if response.code == 400
        raise "Access Denied" if response.code == 401
        raise "Forbidden" if response.code == 403
        raise "Not Found" if [0,404].include?(response.code)
        raise "Method Not Allowed" if response.code == 405
        raise "Not Acceptable" if response.code == 406
        raise "Request Entity Too Large" if response.code == 413
        raise "Internal Server Error" if response.code == 500
        raise "Service Unavailable" if response.code == 503
      end
    end
  end
end
