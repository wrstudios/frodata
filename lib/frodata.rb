require 'uri'
require 'date'
require 'time'
require 'bigdecimal'
require 'nokogiri'
require 'faraday'
require 'logger'
require 'andand'
require 'json'
require 'faraday_middleware'

require 'frodata/concerns/api'
require 'frodata/concerns/authentication'
require 'frodata/concerns/base'
require 'frodata/concerns/caching'
require 'frodata/concerns/connection'
require 'frodata/concerns/verbs'


require 'frodata/middleware'
require 'frodata/middleware/authentication'
require 'frodata/middleware/authentication/token'
require 'frodata/middleware/authorization'
require 'frodata/middleware/caching'
require 'frodata/middleware/custom_headers'
require 'frodata/middleware/gzip'
require 'frodata/middleware/instance_url'
require 'frodata/middleware/logger'
require 'frodata/middleware/odata_headers'
require 'frodata/middleware/raise_error'
require 'frodata/middleware/multipart'
require 'frodata/abstract_client'
require 'frodata/client'
require 'frodata/config'

require 'frodata/version'
require 'frodata/errors'
require 'frodata/property_registry'
require 'frodata/property'
require 'frodata/properties'
require 'frodata/navigation_property'
require 'frodata/entity'
require 'frodata/entity_container'
require 'frodata/entity_set'
require 'frodata/query'
require 'frodata/schema'
require 'frodata/service'
require 'frodata/service_registry'

require 'frodata/railtie' if defined?(::Rails)

# The FrOData gem provides a convenient way to interact with OData V4 services from
# Ruby. Please look to the {file:README.md README} for how to get started using
# the FrOData gem.
module FrOData
  Error               = Class.new(StandardError)
  ServerError         = Class.new(Error)
  AuthenticationError = Class.new(Error)
  UnauthorizedError   = Class.new(Error)
  APIVersionError     = Class.new(Error)

  class << self
    def new(*args, &block)
      FrOData::Client.new(*args, &block)
    end
  end
end
