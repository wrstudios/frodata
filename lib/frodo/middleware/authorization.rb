# frozen_string_literal: true

module Frodo
  # Piece of middleware that simply injects the OAuth token into the request
  # headers.
  class Middleware::Authorization < Frodo::Middleware
    AUTH_HEADER = 'Authorization'

    def call(env)
      env[:request_headers][AUTH_HEADER] = %(Bearer #{token})
      @app.call(env)
    end

    def token
      @options[:oauth_token]
    end
  end
end
