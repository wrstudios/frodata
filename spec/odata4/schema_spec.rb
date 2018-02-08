require 'spec_helper'

describe OData4::Schema do
  let(:subject) { OData4::Schema.new(namespace, service) }
  let(:service) do
    OData4::Service.open('http://services.odata.org/V4/OData/OData.svc', metadata_file: metadata_file)
  end
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:namespace) { service.metadata.xpath('//Schema').first }

  let(:entity_types) { %w{Product FeaturedProduct ProductDetail Category Supplier Person Customer Employee PersonDetail Advertisement} }
  let(:entity_sets) { %w{Products ProductDetails Categories Suppliers Persons PersonDetails Advertisements} }
  let(:entity_set_types) { %w{Product ProductDetail Category Supplier Person PersonDetail Advertisement} }
  let(:complex_types) { %w{Address} }
  let(:enum_types) { %w{ProductStatus} }

  describe '#namespace' do
    it { expect(subject).to respond_to(:namespace) }
    it "returns the schema's namespace attribute" do
      expect(subject.namespace).to eq('ODataDemo')
    end
  end

  describe '#actions' do
    # TBD
  end

  describe '#annotations' do
    # TBD
  end

  describe '#complex_types' do
    it { expect(subject).to respond_to(:complex_types) }
    it { expect(subject.complex_types.size).to eq(1) }
    it { expect(subject.complex_types.keys).to eq(complex_types) }
  end

  describe '#entity_types' do
    it { expect(subject).to respond_to(:entity_types) }
    it { expect(subject.entity_types.size).to eq(10) }
    it { expect(subject.entity_types).to eq(entity_types) }
  end

  describe '#entity_sets' do
    it { expect(subject).to respond_to(:entity_sets) }
    it { expect(subject.entity_sets.size).to eq(7) }
    it { expect(subject.entity_sets.keys).to eq(entity_sets) }
    it { expect(subject.entity_sets.values).to eq(entity_set_types) }
  end

  describe '#enum_types' do
    it { expect(subject).to respond_to(:enum_types) }
    it { expect(subject.enum_types.size).to eq(1) }
    it { expect(subject.enum_types.keys).to eq(enum_types)}
  end

  describe '#functions' do
    # TBD
  end

  describe '#terms' do
    # TBD
  end

  describe '#type_definitions' do
    # TBD
  end

end
