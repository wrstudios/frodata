require 'spec_helper'

describe OData::ComplexType, vcr: {cassette_name: 'v4/complex_type_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::ComplexType.new(name: 'Address', service: service) }
  let(:service) { OData::ServiceRegistry['ODataDemo'] }

  describe '.new' do
    it 'requires type name' do
      expect {
        OData::ComplexType.new(service: service)
      }.to raise_error(ArgumentError)
    end

    it 'requires service instance' do
      expect {
        OData::ComplexType.new(name: 'Address')
      }.to raise_error(ArgumentError)
    end

    it 'requires name to refer to a valid complex type' do
      expect {
        OData::ComplexType.new(name: 'NotAType', service: service)
      }.to raise_error(ArgumentError)
    end
  end

  it { expect(subject).to respond_to(:name) }
  it { expect(subject).to respond_to(:namespace) }
  it { expect(subject).to respond_to(:property_names) }
  it { expect(subject).to respond_to(:[]) }
  it { expect(subject).to respond_to(:[]=) }
  it { expect(subject).to respond_to(:type) }

  describe 'is properly parsed from service metadata' do
    it { expect(subject.name).to eq('Address') }
    it { expect(subject.namespace).to eq('ODataDemo') }
    it { expect(subject.type).to eq('ODataDemo.Address') }
    it { expect(subject.property_names).to eq(%w{Street City State ZipCode Country}) }

    it { expect(subject['Street']).to be_nil }
    it { expect(subject['City']).to be_nil }
    it { expect(subject['State']).to be_nil }
    it { expect(subject['ZipCode']).to be_nil }
    it { expect(subject['Country']).to be_nil }

    it { subject['Street'] = 'Test'; expect(subject['Street']).to eq('Test') }
    it { subject['City'] = 'Test'; expect(subject['City']).to eq('Test') }
    it { subject['State'] = 'Test'; expect(subject['State']).to eq('Test') }
    it { subject['ZipCode'] = 'Test'; expect(subject['ZipCode']).to eq('Test') }
    it { subject['Country'] = 'Test'; expect(subject['Country']).to eq('Test') }
  end

  describe '#to_xml' do
    let(:builder) do
      Nokogiri::XML::Builder.new do |xml|
        xml.entry(
          'xmlns'           => 'http://www.w3.org/2005/Atom',
          'xmlns:data'      => 'http://docs.oasis-open.org/odata/ns/data',
          'xmlns:metadata'  => 'http://docs.oasis-open.org/odata/ns/metadata',
        ) do
          subject.to_xml(xml)
        end
      end
    end
    let(:xml) { Nokogiri::XML(builder.to_xml) }

    before(:each) do
      xml.remove_namespaces!
    end

    it { expect(xml.xpath("/entry/Address[@type='ODataDemo.Address']").count).to eq(1) }
    it { expect(xml.xpath('/entry/Address/Street').count).to eq(1) }
    it { expect(xml.xpath('/entry/Address/City').count).to eq(1) }
    it { expect(xml.xpath('/entry/Address/State').count).to eq(1) }
    it { expect(xml.xpath('/entry/Address/ZipCode').count).to eq(1) }
    it { expect(xml.xpath('/entry/Address/Country').count).to eq(1) }
  end
end
