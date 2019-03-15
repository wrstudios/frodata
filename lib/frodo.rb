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

require 'frodo/concerns/api'
require 'frodo/concerns/authentication'
require 'frodo/concerns/base'
require 'frodo/concerns/caching'
require 'frodo/concerns/connection'
require 'frodo/concerns/verbs'


require 'frodo/middleware'
require 'frodo/middleware/authentication'
require 'frodo/middleware/authentication/token'
require 'frodo/middleware/authorization'
require 'frodo/middleware/caching'
require 'frodo/middleware/custom_headers'
require 'frodo/middleware/gzip'
require 'frodo/middleware/instance_url'
require 'frodo/middleware/logger'
require 'frodo/middleware/odata_headers'
require 'frodo/middleware/raise_error'
require 'frodo/middleware/multipart'
require 'frodo/abstract_client'
require 'frodo/client'
require 'frodo/config'

require 'frodo/version'
require 'frodo/errors'
require 'frodo/property_registry'
require 'frodo/property'
require 'frodo/properties'
require 'frodo/navigation_property'
require 'frodo/entity'
require 'frodo/entity_container'
require 'frodo/entity_set'
require 'frodo/query'
require 'frodo/schema'
require 'frodo/service'
require 'frodo/service_registry'

require 'frodo/railtie' if defined?(::Rails)

# The Frodo gem provides a convenient way to interact with OData V4 services from
# Ruby. Please look to the {file:README.md README} for how to get started using
# the Frodo gem.
module Frodo
  Error               = Class.new(StandardError)
  ServerError         = Class.new(Error)
  AuthenticationError = Class.new(Error)
  UnauthorizedError   = Class.new(Error)
  APIVersionError     = Class.new(Error)

  class << self
    def new(*args, &block)
      Frodo::Client.new(*args, &block)
    end
  end
end
