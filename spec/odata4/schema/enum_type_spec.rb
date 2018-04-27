require 'spec_helper'

describe OData4::Schema::EnumType, vcr: {cassette_name: 'schema/enum_type_specs'} do
  before(:example) do
    OData4::Service.new('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo', metadata_file: metadata_file)
  end

  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:service) { OData4::ServiceRegistry['ODataDemo'] }

  let(:enum_type) { service.enum_types['ODataDemo.ProductStatus'] }
  let(:subject) { enum_type.property_class.new('ProductStatus', nil) }

  describe 'is properly parsed from service metadata' do
    it { expect(enum_type.name).to eq('ProductStatus') }
    it { expect(enum_type.namespace).to eq('ODataDemo') }
    it { expect(enum_type.type).to eq('ODataDemo.ProductStatus') }
    it { expect(enum_type.is_flags?).to eq(false) }
    it { expect(enum_type.underlying_type).to eq('Edm.Byte') }
    it { expect(enum_type.members.values).to eq(%w{Available LowStock Backordered Discontinued}) }
  end

  # Check property instance inheritance hierarchy
  it { expect(subject).to be_a(OData4::Property) }
  it { expect(subject).to be_a(OData4::Properties::Enum) }

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

    it 'allows setting by numeric value' do
      expect {
        subject.value = 1
      }.not_to raise_error
      expect(subject.value).to eq('LowStock')
    end

    context 'when `IsFlags` is false' do
      it 'does not allow setting multiple values' do
        expect {
          subject.value = 'Available, Backordered'
        }.to raise_error(ArgumentError)
      end
    end

    context 'when `IsFlags` is true' do
      before do
        subject.define_singleton_method(:is_flags?) { true }
      end

      it 'allows setting multiple values' do
        subject.value = 'Available, Backordered'
        expect(subject.value).to eq(%w[Available Backordered])
      end

      it 'does not allow setting invalid values' do
        expect {
          subject.value = 'Available, Invalid'
        }.to raise_error(ArgumentError)
      end

      it 'allows setting by numeric value' do
        expect {
          subject.value = '0, 1'
        }.not_to raise_error
        expect(subject.value).to eq(%w[Available LowStock])
      end
    end
  end

  describe 'lenient validation' do
    let(:subject) do
      enum_type.property_class.new('ProductStatus', nil, strict: false)
    end

    describe '#value=' do
      it 'ignores invalid values' do
        expect {
          subject.value = 'Invalid'
        }.not_to raise_error

        expect(subject.value).to be_nil
      end

      context 'when `IsFlags` is true' do
        before do
          subject.define_singleton_method(:is_flags?) { true }
        end

        it 'ignores invalid values' do
          expect {
            subject.value = 'Available, Invalid'
          }.not_to raise_error

          expect(subject.value).to eq(['Available'])
        end
      end
    end
  end
end
