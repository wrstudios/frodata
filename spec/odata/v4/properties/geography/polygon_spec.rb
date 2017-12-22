require 'spec_helper'

describe OData::Properties::Geography::Polygon do
  let(:subject) { OData::Properties::Geography::Polygon.new('Area', coordinates) }
  let(:coordinates) { [
      [100.0, 0.0],
      [101.0, 0.0],
      [101.0, 1.0],
      [100.0, 1.0],
      [100.0, 0.0]
  ] }
  let(:new_coordinates) { [
      [200.0, 10.0],
      [201.0, 10.0],
      [201.0, 11.0],
      [200.0, 11.0],
      [200.0, 10.0]
  ] }
  let(:property_as_json) { {
    type: 'Polygon',
    coordinates: [
      [100.0, 0.0],
      [101.0, 0.0],
      [101.0, 1.0],
      [100.0, 1.0],
      [100.0, 0.0]
    ]
  } }
  let(:property_as_xml) { <<-END }
    <data:Area metadata:type="Edm.GeographyPolygon">
      <gml:Polygon>
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

  describe '#type' do
    it { expect(subject.type).to eq('Edm.GeographyPolygon') }
  end

  describe '#value' do
    it { expect(subject.value).to eq(coordinates) }
  end

  describe '#value=' do
    it { expect { subject.value = 'invalid' }.to raise_error(ArgumentError) }

    it { expect(lambda {
      subject.value = "geography'SRID=0;Polygon((200.0 10.0,201.0 10.0,201.0 11.0,200.0 11.0,200.0 10.0))'"
      subject.value
    }.call).to eq(new_coordinates) }

    it { expect(lambda {
      subject.value = new_coordinates
      subject.value
    }.call).to eq(new_coordinates) }
  end

  describe '#url_value' do
    it { expect(subject.url_value).to eq("geography'SRID=0;Polygon((100.0 0.0,101.0 0.0,101.0 1.0,100.0 1.0,100.0 0.0))'") }
  end

  describe '#json_value' do
    it 'renders property value as a hash' do
      expect(subject.json_value).to eq(property_as_json)
    end
  end

  describe '#to_xml' do
    let(:builder) do
      Nokogiri::XML::Builder.new do |xml|
        xml.entry(OData::Entity::XML_NAMESPACES) do
          subject.to_xml(xml)
        end
      end
    end
    let(:xml) { Nokogiri::XML(builder.to_xml) }
    let(:property_xml) { xml.root.element_children.first.to_s }

    it { expect(property_xml).to be_equivalent_to(property_as_xml) }
  end

  describe '.from_xml' do
    let(:subject) { OData::Properties::Geography::Polygon.from_xml(property_xml) }
    let(:xml_doc) do
      Nokogiri::XML::Builder.new do |xml|
        xml.entry(OData::Entity::XML_NAMESPACES)
      end.to_xml
    end
    let(:property_xml) do
      document = Nokogiri::XML(xml_doc)
      document.root << property_as_xml
      document.remove_namespaces!.root.element_children.first
    end

    it { expect(subject.value).to eq(coordinates) }
  end
end
