require 'frodo/properties/geography/base'
require 'frodo/properties/geography/point'
require 'frodo/properties/geography/line_string'
require 'frodo/properties/geography/polygon'

Frodo::Properties::Geography.constants.each do |property_name|
  next if property_name =~ /Base$/
  klass = Frodo::Properties::Geography.const_get(property_name)
  if klass.is_a?(Class)
    property = klass.new('test', nil)
    Frodo::PropertyRegistry.add(property.type, property.class)
  end
end
