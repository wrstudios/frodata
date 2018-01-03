require 'spec_helper'
require_relative 'shared_examples'

describe OData::Properties::Geography::Polygon do
  let(:klass) { OData::Properties::Geography::Polygon }
  let(:property_name) { 'Area' }
  let(:srid) { 4326 }
  let(:coordinates) { [
      [100.0, 0.0],
      [101.0, 0.0],
      [101.0, 1.0],
      [100.0, 1.0],
      [100.0, 0.0]
  ] }
  let(:property_as_text) { "geography'SRID=4326;Polygon((100.0 0.0,101.0 0.0,101.0 1.0,100.0 1.0,100.0 0.0))'" }
  let(:property_as_json) { {
    type: 'Polygon',
    coordinates: [
      [100.0, 0.0],
      [101.0, 0.0],
      [101.0, 1.0],
      [100.0, 1.0],
      [100.0, 0.0]
    ],
    crs: {
      type: 'name',
      properties: { name: 'EPSG:4326' }
    }
  } }
  let(:property_as_xml) { <<-END }
    <data:Area metadata:type="Edm.GeographyPolygon">
      <gml:Polygon gml:srsName="http://www.opengis.net/def/crs/EPSG/0/4326">
        <gml:exterior>
          <gml:LinearRing>
            <gml:pos>100.0 0.0</gml:pos>
            <gml:pos>101.0 0.0</gml:pos>
            <gml:pos>101.0 1.0</gml:pos>
            <gml:pos>100.0 1.0</gml:pos>
            <gml:pos>100.0 0.0</gml:pos>
          </gml:LinearRing>
        </gml:exterior>
      </gml:Polygon>
    </data:Area>
  END
  let(:new_value) { [
      [200.0, 10.0],
      [201.0, 10.0],
      [201.0, 11.0],
      [200.0, 11.0],
      [200.0, 10.0]
  ] }
  let(:new_value_as_text) { "geography'SRID=0;Polygon((200.0 10.0,201.0 10.0,201.0 11.0,200.0 11.0,200.0 10.0))'" }

  it_behaves_like 'a geographic property', 'Edm.GeographyPolygon'
end
