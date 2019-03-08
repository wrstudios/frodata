# frozen_string_literal: true

module FrOData
  # Base class that all middleware can extend. Provides some convenient helper
  # functions.
  class Middleware < Faraday::Middleware
    autoload :RaiseError,     'frodata/middleware/raise_error'
    autoload :Authentication, 'frodata/middleware/authentication'
    autoload :Authorization,  'frodata/middleware/authorization'
    autoload :InstanceURL,    'frodata/middleware/instance_url'
    autoload :Multipart,      'frodata/middleware/multipart'
    autoload :Caching,        'frodata/middleware/caching'
    autoload :Logger,         'frodata/middleware/logger'
    autoload :Gzip,           'frodata/middleware/gzip'
    autoload :CustomHeaders,  'frodata/middleware/custom_headers'

    def initialize(app, client, options)
      @app = app
      @client = client
      @options = options
    end

    # Internal: Proxy to the client.
    def client
      @client
    end

    # Internal: Proxy to the client's faraday connection.
    def connection
      client.send(:connection)
    end
  end
end
