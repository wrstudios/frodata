require 'spec_helper'

describe OData::Properties::Geography::Point do
  let(:subject) { OData::Properties::Geography::Point.new('Location', coordinates) }
  let(:coordinates)    { [ 142.1, 64.1 ]}
  let(:new_coordinates) { [ 100.0, 0.0 ]}

  describe '#type' do
    it { expect(subject.type).to eq('Edm.GeographyPoint') }
  end

  describe '#value' do
    it { expect(subject.value).to eq(coordinates) }
  end

  describe '#value=' do
    it { expect { subject.value = 'invalid' }.to raise_error(ArgumentError) }

    it { expect(lambda {
      subject.value = "geography'SRID=0;Point(100.0 0.0)'"
      subject.value
    }.call).to eq(new_coordinates) }

    it { expect(lambda {
      subject.value = new_coordinates
      subject.value
    }.call).to eq(new_coordinates) }
  end

  describe '#url_value' do
    it { expect(subject.url_value).to eq("geography'SRID=0;Point(142.1 64.1)'") }
  end

  describe '#json_value' do
    it 'renders property value as a hash' do
      expect(subject.json_value).to eq({
        type: 'Point',
        coordinates: coordinates
      })
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
    let(:xml) { Nokogiri::XML(builder.to_xml).remove_namespaces! }

    it { expect(xml.xpath('/entry/Location').count).to eq(1) }
    it { expect(xml.xpath('/entry/Location/Point').count).to eq(1) }
    it { expect(xml.xpath('/entry/Location/Point/pos').count).to eq(1) }
    it { expect(xml.xpath('/entry/Location/Point/pos').map(&:content)).to eq(['142.1 64.1']) }
  end

  describe '.from_xml' do
    let(:subject) { OData::Properties::Geography::Point.from_xml(property_xml) }
    let(:xml_file) { 'spec/fixtures/files/v4/supplier_0.xml' }
    let(:supplier_xml) {
      document = ::Nokogiri::XML(File.open xml_file)
      document.remove_namespaces!
      document.xpath('//entry').first
    }
    let(:property_xml) { supplier_xml.xpath('//Location').first }

    it { expect(subject.value).to eq([47.6316604614258, -122.03547668457]) }
  end
end
