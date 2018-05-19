module FrOData
  class Service
    # Encapsulates a single request to an OData service.
    class Request
      # The OData service against which the request is performed
      attr_reader :service
      # The FrOData::Query that generated this request (optional)
      attr_reader :query
      # The HTTP method for this request
      attr_accessor :method
      # The request format (`:atom`, `:json`, or `:auto`)
      attr_accessor :format

      # Create a new request
      # @param service [FrOData::Service] Where the request will be sent
      # @param url_chunk [String] Request path, relative to the service URL, including query params
      # @param options [Hash] Additional request options
      def initialize(service, url_chunk, options = {})
        @service = service
        @url_chunk = url_chunk
        @method = options.delete(:method) || :get
        @format = options.delete(:format) || :auto
        @query  = options.delete(:query)
        @options = options
      end

      # Return the full request URL (including service base)
      # @return [String]
      def url
        ::URI.join("#{service.service_url}/", ::URI.escape(url_chunk)).to_s
      end

      # The content type for this request. Depends on format.
      # @return [String]
      def content_type
        if format == :auto
          MIME_TYPES.values.join(',')
        elsif MIME_TYPES.has_key? format
          MIME_TYPES[format]
        else
          raise ArgumentError, "Unknown format '#{format}'"
        end
      end

      # Execute the request
      #
      # @param additional_options [Hash] Request options to pass to Faraday
      # @return [FrOData::Service::Response]
      def execute(additional_options = {})
        request_options = service.options[:request].merge(additional_options)

        Response.new(service, query) do
          connection.run_request(method, url_chunk, nil, headers) do |conn|
            conn.options.merge! request_options
          end
        end
      end

      private

      attr_reader :url_chunk

      def connection
        service.connection
      end

      def default_headers
        {
          'OData-Version' => '4.0'
        }
      end

      def headers
        default_headers.merge(@options[:headers] || {})
      end

      def logger
        service.logger
      end
    end
  end
end
