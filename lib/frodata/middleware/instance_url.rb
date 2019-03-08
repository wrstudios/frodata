# frozen_string_literal: true

module FrOData
  # Middleware which asserts that the instance_url is always set
  class Middleware::InstanceURL < FrOData::Middleware
    def call(env)
      # If the connection url_prefix isn't set, we must not be authenticated.
      unless url_prefix_set?
        raise FrOData::UnauthorizedError,
              'Connection prefix not set'
      end

      @app.call(env)
    end

    def url_prefix_set?
      !!(connection.url_prefix&.host)
    end
  end
end
