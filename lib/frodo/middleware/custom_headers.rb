# frozen_string_literal: true

module Frodo
  # Middleware that allows you to specify custom request headers
  # when initializing Frodo client
  class Middleware::CustomHeaders < Frodo::Middleware
    def call(env)
      headers = @options[:request_headers]
      env[:request_headers].merge!(headers) if headers.is_a?(Hash)

      @app.call(env)
    end
  end
end
