module Frodo
  # Authentication middleware used if client_id, client_secret, and client_credentials: true are set
  class Middleware::Authentication::Password < Frodo::Middleware::Authentication
    def params
      { grant_type: 'password',
        client_id: @options[:client_id],
        username: @options[:username],
        password: @options[:password],
        resource: @options[:instance_url],
      }
    end
  end
end
