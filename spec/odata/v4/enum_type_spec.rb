require 'spec_helper'

describe OData::EnumType, vcr: {cassette_name: 'v4/enum_type_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo', metadata_file: metadata_file)
  end

  let(:metadata_file) { 'spec/fixtures/sample_service/v4/metadata.xml' }
  let(:service) { OData::ServiceRegistry['ODataDemo'] }

  describe '.new' do
    it 'requires type name' do
      expect {
        OData::EnumType.new(service: service)
      }.to raise_error(ArgumentError)
    end

    it 'requires service instance' do
      expect {
        OData::EnumType.new(name: 'Address')
      }.to raise_error(ArgumentError)
    end

    it 'requires name to refer to a valid enum type' do
      expect {
        OData::EnumType.new(name: 'NotAType', service: service)
      }.to raise_error(ArgumentError)
    end
  end

  let(:enum_type) { OData::EnumType.new(name: 'ProductStatus', service: service) }
  let(:subject) { enum_type.property_class.new('ProductStatus', nil) }

  describe 'is properly parsed from service metadata' do
    it { expect(enum_type.name).to eq('ProductStatus') }
    it { expect(enum_type.namespace).to eq('ODataDemo') }
    it { expect(enum_type.type).to eq('ODataDemo.ProductStatus') }
    it { expect(enum_type.members.keys).to eq(%w{Available LowStock Backordered Discontinued}) }
  end

  # Check property instance inheritance hierarchy
  it { expect(subject).to be_a(OData::Property) }
  it { expect(subject).to be_a(OData::EnumType::Property) }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject).to respond_to(:type) }
  it { expect(subject).to respond_to(:members) }

  describe '#value=' do
    it 'allows setting a valid value' do
      subject.value = 'Available'
      expect(subject.value).to eq('Available')
    end

    it 'does not allow setting an invalid value' do
      expect {
        subject.value = 'Invalid'
      }.to raise_error(ArgumentError)
    end
  end
end
