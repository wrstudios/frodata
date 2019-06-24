# frozen_string_literal: true

module Frodo
  module Concerns
    module Base
      attr_reader :options

      MIME_TYPES = {
        json:  'application/json'
      }

      # Public: Creates a new client instance
      #
      # opts - A hash of options to be passed in (default: {}).
      #
      #        :oauth_token             - The String oauth access token to authenticate
      #                                   API calls (required unless password
      #                                   authentication is used).
      #        :refresh_token           - The String refresh token to obtain fresh
      #                                   OAuth access tokens (required if oauth
      #                                   authentication is used).
      #        :instance_url            - The String base url for all api requests
      #                                   (required if oauth authentication is used).
      #
      #        :client_id               - The oauth client id to use. Needed for both
      #                                   password and oauth authentication
      #        :client_secret           - The oauth client secret to use.
      #
      #        :host                    - The String hostname to use during
      #                                   authentication requests
      #                                   (default: 'login.microsoftonline.com').
      #
      #        :base_path              - The base path for the REST api. (default: '/')
      #
      #        :authentication_retries  - The number of times that client
      #                                   should attempt to reauthenticate
      #                                   before raising an exception (default: 3).
      #
      #        :compress                - Set to true to have Dynamics compress the
      #                                   response (default: false).
      #        :raw_json                 - Set to true to skip the conversion of
      #                                   Entities responses (default: false).
      #        :timeout                 - Faraday connection request read/open timeout.
      #                                   (default: nil).
      #
      #        :proxy_uri               - Proxy URI: 'http://proxy.example.com:port' or
      #                                   'http://user@pass:proxy.example.com:port'
      #
      #        :authentication_callback - A Proc that is called with the response body
      #                                   after a successful authentication.
      #
      #        :request_headers         - A hash containing custom headers that will be
      #                                   appended to each request

      def initialize(opts = {})
        raise ArgumentError, 'Please specify a hash of options' unless opts.is_a?(Hash)

        # allow injecting the service for performance purpose such as
        # when you have already a local schema
        @service = opts.delete(:service)

        @options = Hash[Frodo.configuration.options.map do |option|
          [option, Frodo.configuration.send(option)]
        end]

        @options.merge! opts
        yield builder if block_given?
      end

      def instance_url
        authenticate! unless options[:instance_url]
        options[:instance_url]
      end

      def service
        @service ||= Frodo::Service.new(instance_url, strict: false, metadata_document: metadata_on_init)
      end

      def inspect
        "#<#{self.class} @options=#{@options.inspect}>"
      end
    end
  end
end
