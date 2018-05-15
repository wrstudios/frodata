require 'uri'
require 'date'
require 'time'
require 'bigdecimal'
require 'nokogiri'
require 'faraday'
require 'logger'
require 'andand'
require 'json'

# require 'active_support'
# require 'active_support/core_ext'
# require 'active_support/concern'

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
  # Your code goes here...
end
