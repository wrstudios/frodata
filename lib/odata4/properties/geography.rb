require 'odata4/properties/geography/base'
require 'odata4/properties/geography/point'
require 'odata4/properties/geography/line_string'
require 'odata4/properties/geography/polygon'

OData4::Properties::Geography.constants.each do |property_name|
  next if property_name =~ /Base$/
  klass = OData4::Properties::Geography.const_get(property_name)
  if klass.is_a?(Class)
    property = klass.new('test', nil)
    OData4::PropertyRegistry.add(property.type, property.class)
  end
end
