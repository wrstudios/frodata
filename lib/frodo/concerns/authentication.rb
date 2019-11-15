# frozen_string_literal: true

module Frodo
  module Concerns
    module Authentication
      # Public: Force an authentication
      def authenticate!
        unless authentication_middleware
          raise AuthenticationError, 'No authentication middleware present'
        end

        middleware = authentication_middleware.new nil, self, options
        middleware.authenticate!
      end

      # Internal: Determines what middleware will be used based on the options provided
      def authentication_middleware
        if oauth_refresh?
          return Frodo::Middleware::Authentication::Token
        end
        if password?
          return Frodo::Middleware::Authentication::Password
        end
        if client_credentials?
          return Frodo::Middleware::Authentication::ClientCredentials
        end
      end

      # Internal: Returns true if oauth password grant
      # should be used for authentication.
      def password?
        options[:username] &&
          options[:password] &&
          options[:client_id] &&
          options[:tenant_id]
      end

      # Internal: Returns true if oauth client_credentials flow should be used for
      # authentication.
      def client_credentials?
        options[:tenant_id] &&
          options[:client_id] &&
          options[:client_secret]
      end

      # Internal: Returns true if oauth token refresh flow should be used for
      # authentication.
      def oauth_refresh?
        options[:refresh_token] &&
          options[:client_id] &&
          options[:client_secret]
      end
    end
  end
end
