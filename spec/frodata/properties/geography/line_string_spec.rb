require 'spec_helper'
require_relative 'shared_examples'

describe FrOData::Properties::Geography::LineString do
  let(:klass) { FrOData::Properties::Geography::LineString }
  let(:property_name) { 'Boundary' }
  let(:srid)  { 4326 }
  let(:coordinates)     { [[100.0, 0.0], [101.0, 1.0]] }
  let(:property_as_text) { "geography'SRID=4326;LineString(100.0 0.0,101.0 1.0)'" }
  let(:property_as_json) { {
    type: 'LineString',
    coordinates: [
      [100.0, 0.0],
      [101.0, 1.0]
    ],
    crs: {
      type: 'name',
      properties: { name: 'EPSG:4326' }
    }
  } }
  let(:property_as_xml) { <<-END }
    <data:Boundary metadata:type="Edm.GeographyLineString">
      <gml:LineString gml:srsName="http://www.opengis.net/def/crs/EPSG/0/4326">
        <gml:pos>100.0 0.0</gml:pos>
        <gml:pos>101.0 1.0</gml:pos>
      </gml:LineString>
    </data:Boundary>
  END
  let(:new_value) { [[0.0, 100.0], [1.0, 101.0]] }
  let(:new_value_as_text) { "geography'SRID=0;LineString(0.0 100.0,1.0 101.0)'" }

  it_behaves_like 'a geographic property', 'Edm.GeographyLineString'
end
