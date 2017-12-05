require 'spec_helper'

describe OData::ComplexType, vcr: {cassette_name: 'v4/complex_type_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

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

  let(:address) { {
      'Street'  => '123 Main St',
      'City'    => 'Huntington Beach',
      'State'   => 'CA',
      'ZipCode' => '92648',
      'Country' => 'USA'
  } }

  let(:complex_type) { OData::ComplexType.new(name: 'Address', service: service) }
  let(:subject) { complex_type.property_class.new('Address', nil) }

  describe 'is properly parsed from service metadata' do
    it { expect(complex_type.name).to eq('Address') }
    it { expect(complex_type.namespace).to eq('ODataDemo') }
    it { expect(complex_type.type).to eq('ODataDemo.Address') }
    it { expect(complex_type.property_names).to eq(%w{Street City State ZipCode Country}) }
  end

  # Check property instance inheritance hierarchy
  it { expect(subject).to be_a(OData::Property) }
  it { expect(subject).to be_a(OData::ComplexType::Property) }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject).to respond_to(:type) }
  it { expect(subject).to respond_to(:property_names) }
  it { expect(subject).to respond_to(:[]) }
  it { expect(subject).to respond_to(:[]=) }

  it { expect(subject[ 'Street']).to be_nil }
  it { expect(subject[   'City']).to be_nil }
  it { expect(subject[  'State']).to be_nil }
  it { expect(subject['ZipCode']).to be_nil }
  it { expect(subject['Country']).to be_nil }

  describe '#[]=' do
    before do
      address.each { |key, val| subject[key] = val }
    end

    it { expect(subject.value).to eq(address) }

    it { expect(subject[ 'Street']).to eq(address[ 'Street']) }
    it { expect(subject[   'City']).to eq(address[   'City']) }
    it { expect(subject[  'State']).to eq(address[  'State']) }
    it { expect(subject['ZipCode']).to eq(address['ZipCode']) }
    it { expect(subject['Country']).to eq(address['Country']) }
  end

  describe '#value=' do
    before { subject.value = address }

    it { expect(subject.value).to eq(address) }

    it { expect(subject[ 'Street']).to eq(address[ 'Street']) }
    it { expect(subject[   'City']).to eq(address[   'City']) }
    it { expect(subject[  'State']).to eq(address[  'State']) }
    it { expect(subject['ZipCode']).to eq(address['ZipCode']) }
    it { expect(subject['Country']).to eq(address['Country']) }
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
      subject.value = address
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
