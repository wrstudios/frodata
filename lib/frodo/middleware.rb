# frozen_string_literal: true

module Frodo
  # Base class that all middleware can extend. Provides some convenient helper
  # functions.
  class Middleware < Faraday::Middleware
    autoload :RaiseError,     'frodo/middleware/raise_error'
    autoload :Authentication, 'frodo/middleware/authentication'
    autoload :Authorization,  'frodo/middleware/authorization'
    autoload :InstanceURL,    'frodo/middleware/instance_url'
    autoload :Multipart,      'frodo/middleware/multipart'
    autoload :Caching,        'frodo/middleware/caching'
    autoload :Logger,         'frodo/middleware/logger'
    autoload :Gzip,           'frodo/middleware/gzip'
    autoload :CustomHeaders,  'frodo/middleware/custom_headers'

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
