require 'odata/properties/geography/base'
require 'odata/properties/geography/point'
require 'odata/properties/geography/line_string'
require 'odata/properties/geography/polygon'

OData::Properties::Geography.constants.each do |property_name|
  next if property_name =~ /Base$/
  klass = OData::Properties::Geography.const_get(property_name)
  if klass.is_a?(Class)
    property = klass.new('test', nil)
    OData::PropertyRegistry.add(property.type, property.class)
  end
end
