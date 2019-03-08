# frozen_string_literal: true

module FrOData
  # Authentication middleware used if oauth_token and refresh_token are set
  class Middleware::Authentication::Token < FrOData::Middleware::Authentication
    def params
      { grant_type: 'refresh_token',
        refresh_token: @options[:refresh_token],
        client_id: @options[:client_id],
        client_secret: @options[:client_secret] }
    end
  end
end
