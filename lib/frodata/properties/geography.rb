require 'frodata/properties/geography/base'
require 'frodata/properties/geography/point'
require 'frodata/properties/geography/line_string'
require 'frodata/properties/geography/polygon'

FrOData::Properties::Geography.constants.each do |property_name|
  next if property_name =~ /Base$/
  klass = FrOData::Properties::Geography.const_get(property_name)
  if klass.is_a?(Class)
    property = klass.new('test', nil)
    FrOData::PropertyRegistry.add(property.type, property.class)
  end
end
