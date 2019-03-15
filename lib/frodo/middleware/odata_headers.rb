# frozen_string_literal: true

module Frodo
    # Middleware that allows you to specify custom request headers
    # when initializing Frodo client
    class Middleware::OdataHeaders < Frodo::Middleware
      def call(env)
        env[:request_headers].merge!({'OData-Version' => '4.0', 'Content-type' => 'application/json'})

        @app.call(env)
      end
    end
  end
