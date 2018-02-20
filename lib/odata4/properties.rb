# Modules
require 'odata4/properties/number'

# Implementations
require 'odata4/properties/binary'
require 'odata4/properties/boolean'
require 'odata4/properties/collection'
require 'odata4/properties/date'
require 'odata4/properties/date_time'
require 'odata4/properties/date_time_offset'
require 'odata4/properties/decimal'
require 'odata4/properties/float'
require 'odata4/properties/geography'
require 'odata4/properties/guid'
require 'odata4/properties/integer'
require 'odata4/properties/string'
require 'odata4/properties/time'
require 'odata4/properties/time_of_day'

OData4::Properties.constants.each do |property_name|
  klass = OData4::Properties.const_get(property_name)
  if klass.is_a?(Class)
    property = klass.new('test', nil)
    OData4::PropertyRegistry.add(property.type, property.class)
  end
end
