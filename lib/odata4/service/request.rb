module OData4
  class Service
    # Encapsulates a single request to an OData service.
    class Request
      # The OData service against which the request is performed
      attr_reader :service
      # The OData4::Query that generated this request (optional)
      attr_reader :query
      # The HTTP method for this request
      attr_accessor :method
      # The request format (`:atom`, `:json`, or `:auto`)
      attr_accessor :format

      # Create a new request
      # @param service [OData4::Service] Where the request will be sent
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
      # @param additional_options [Hash] options to pass to Typhoeus
      # @return [OData4::Service::Response]
      def execute(additional_options = {})
        logger.info "Requesting #{method.to_s.upcase} #{url}..."
        Response.new(service, query) do
          connection.run_request(method, url, nil, headers) do |conn|
            conn.options.merge! request_options(additional_options)
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
          'Accept'        => content_type,
          'Content-Type'  => content_type,
          'OData-Version' => '4.0'
        }
      end

      def headers
        default_headers.merge(@options[:headers] || {})
      end

      def request_options(additional_options = {})
        service.options[:request].merge(additional_options)
      end

      def logger
        service.logger
      end
    end
  end
end
