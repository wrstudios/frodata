# frozen_string_literal: true

module Frodo
  module Concerns
    module Connection
      # Public: The Faraday::Builder instance used for the middleware stack. This
      # can be used to insert an custom middleware.
      #
      # Examples
      #
      #   # Add the instrumentation middleware for Rails.
      #   client.middleware.use FaradayMiddleware::Instrumentation
      #
      # Returns the Faraday::Builder for the Faraday connection.
      def middleware
        connection.builder
      end
      alias builder middleware

      private

      # Internal: Internal faraday connection where all requests go through
      def connection
        @connection ||= Faraday.new(options[:instance_url],
                                    connection_options) do |builder|

          # Converts the request into JSON.
          builder.request :json
          # Handles reauthentication for 403 responses.
          if authentication_middleware
            builder.use authentication_middleware, self, options
          end
          # Sets the oauth token in the headers.
          builder.use Frodo::Middleware::Authorization, self, options
          # Ensures the instance url is set.
          builder.use Frodo::Middleware::InstanceURL, self, options
          # Caches GET requests.
          builder.use Frodo::Middleware::Caching, cache, options if cache
          # Follows 30x redirects.
          builder.use FaradayMiddleware::FollowRedirects
          # Raises errors for 40x responses.
          builder.use Frodo::Middleware::RaiseError
          # Parses returned JSON response into a hash.
          builder.response :json, content_type: /\bjson$/
          # Compress/Decompress the request/response
          unless adapter == :httpclient
            builder.use Frodo::Middleware::Gzip, self, options
          end
          # Inject OData headers into requests
          builder.use Frodo::Middleware::OdataHeaders, self, options
          # Inject custom headers into requests
          builder.use Frodo::Middleware::CustomHeaders, self, options
          # Log request/responses
          if Frodo.log?
            builder.use Frodo::Middleware::Logger,
                        Frodo.configuration.logger,
                        options
          end

          builder.adapter adapter
        end
      end

      def adapter
        options[:adapter]
      end

      # Internal: Faraday Connection options
      def connection_options
        { request: {
            timeout: options[:timeout],
            open_timeout: options[:timeout]
          },
          proxy: options[:proxy_uri],
          ssl: options[:ssl] }
      end
    end
  end
end
