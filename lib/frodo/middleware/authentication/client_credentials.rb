module Frodo
  # Authentication middleware used if client_id, client_secret, and client_credentials: true are set
  class Middleware::Authentication::ClientCredentials < Frodo::Middleware::Authentication
    def params
      { grant_type: 'client_credentials',
        client_id: @options[:client_id],
        client_secret: @options[:client_secret] }
    end
  end
end
