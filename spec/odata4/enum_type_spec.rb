require 'spec_helper'

describe OData4::EnumType, vcr: {cassette_name: 'enum_type_specs'} do
  before(:example) do
    OData4::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo', metadata_file: metadata_file)
  end

  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:service) { OData4::ServiceRegistry['ODataDemo'] }

  describe '.new' do
    it 'requires type name' do
      expect {
        OData4::EnumType.new(service: service)
      }.to raise_error(ArgumentError)
    end

    it 'requires service instance' do
      expect {
        OData4::EnumType.new(name: 'Address')
      }.to raise_error(ArgumentError)
    end

    it 'requires name to refer to a valid enum type' do
      expect {
        OData4::EnumType.new(name: 'NotAType', service: service)
      }.to raise_error(ArgumentError)
    end
  end

  let(:enum_type) { service.enum_types['ProductStatus'] }
  let(:subject) { enum_type.property_class.new('ProductStatus', nil) }

  describe 'is properly parsed from service metadata' do
    it { expect(enum_type.name).to eq('ProductStatus') }
    it { expect(enum_type.namespace).to eq('ODataDemo') }
    it { expect(enum_type.type).to eq('ODataDemo.ProductStatus') }
    it { expect(enum_type.is_flags?).to eq(false) }
    it { expect(enum_type.underlying_type).to eq('Edm.Byte') }
    it { expect(enum_type.members.keys).to eq(%w{Available LowStock Backordered Discontinued}) }
  end

  # Check property instance inheritance hierarchy
  it { expect(subject).to be_a(OData4::Property) }
  it { expect(subject).to be_a(OData4::EnumType::Property) }

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

    context 'with multiple values' do
      context 'when is_flags=false' do
        it 'does not allow setting valid values' do
          expect {
            subject.value = 'Available, Backordered'
          }.to raise_error(ArgumentError)
        end
      end

      context 'when is_flags=true' do
        before do
          subject.define_singleton_method(:is_flags?) { true }
        end

        it 'allows setting valid values' do
          subject.value = 'Available, Backordered'
          expect(subject.value).to eq('Available,Backordered')
        end

        it 'does not allow setting an invalid value' do
          expect {
            subject.value = 'Available, Invalid'
          }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
