# Modules
require 'frodo/properties/number'

# Implementations
require 'frodo/properties/binary'
require 'frodo/properties/boolean'
require 'frodo/properties/collection'
require 'frodo/properties/complex'
require 'frodo/properties/date'
require 'frodo/properties/date_time'
require 'frodo/properties/date_time_offset'
require 'frodo/properties/decimal'
require 'frodo/properties/enum'
require 'frodo/properties/float'
require 'frodo/properties/geography'
require 'frodo/properties/guid'
require 'frodo/properties/integer'
require 'frodo/properties/string'
require 'frodo/properties/time'
require 'frodo/properties/time_of_day'

Frodo::Properties.constants.each do |property_name|
  klass = Frodo::Properties.const_get(property_name)
  if klass.is_a?(Class)
    begin
      property = klass.new('test', nil)
      Frodo::PropertyRegistry.add(property.type, property.class)
    rescue NotImplementedError
      # Abstract type classes cannot be instantiated, ignore
    end
  end
end
