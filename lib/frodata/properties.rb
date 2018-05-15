# Modules
require 'frodata/properties/number'

# Implementations
require 'frodata/properties/binary'
require 'frodata/properties/boolean'
require 'frodata/properties/collection'
require 'frodata/properties/complex'
require 'frodata/properties/date'
require 'frodata/properties/date_time'
require 'frodata/properties/date_time_offset'
require 'frodata/properties/decimal'
require 'frodata/properties/enum'
require 'frodata/properties/float'
require 'frodata/properties/geography'
require 'frodata/properties/guid'
require 'frodata/properties/integer'
require 'frodata/properties/string'
require 'frodata/properties/time'
require 'frodata/properties/time_of_day'

FrOData::Properties.constants.each do |property_name|
  klass = FrOData::Properties.const_get(property_name)
  if klass.is_a?(Class)
    begin
      property = klass.new('test', nil)
      FrOData::PropertyRegistry.add(property.type, property.class)
    rescue NotImplementedError
      # Abstract type classes cannot be instantiated, ignore
    end
  end
end
