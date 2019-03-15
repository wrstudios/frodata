require 'spec_helper'
require_relative 'shared_examples'

describe Frodo::Properties::Geography::Point do
  let(:klass) { Frodo::Properties::Geography::Point }
  let(:property_name) { 'Location' }
  let(:srid)  { 4326 }
  let(:coordinates)    { [ 142.1, 64.1 ]}
  let(:property_as_text) { "geography'SRID=4326;Point(142.1 64.1)'" }
  let(:property_as_json) { {
    type: 'Point',
    coordinates: [142.1, 64.1],
    crs: {
      type: 'name',
      properties: { name: 'EPSG:4326' }
    }
  } }
  let(:property_as_xml) { <<-END }
    <data:Location metadata:type="Edm.GeographyPoint">
      <gml:Point gml:srsName="http://www.opengis.net/def/crs/EPSG/0/4326">
        <gml:pos>142.1 64.1</gml:pos>
      </gml:Point>
    </data:Location>
  END
  let(:new_value) { [ 100.0, 0.0 ] }
  let(:new_value_as_text) { "geography'SRID=0;Point(100.0 0.0)'" }

  it_behaves_like 'a geographic property', 'Edm.GeographyPoint'
end
