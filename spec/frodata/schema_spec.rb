require 'spec_helper'

describe FrOData::Schema do
  let(:subject) { FrOData::Schema.new(schema_xml, service) }
  let(:service) do
    FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', metadata_file: metadata_file)
  end
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:schema_xml) { service.metadata.xpath('//Schema').first }

  let(:entity_types) { %w{Product FeaturedProduct ProductDetail Category Supplier Person Customer Employee PersonDetail Advertisement} }
  let(:complex_types) { %w{Address} }
  let(:enum_types) { %w{Vertical EthicalAttribute ProductStatus} }

  describe '#namespace' do
    it { expect(subject).to respond_to(:namespace) }
    it "returns the schema's namespace attribute" do
      expect(subject.namespace).to eq('ODataDemo')
    end
  end

  describe '#actions' do
    # TODO add a action definition to metadata
    it { expect(subject).to respond_to(:actions) }
    it { expect(subject.actions.size).to eq(0) }
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

  describe '#enum_types' do
    it { expect(subject).to respond_to(:enum_types) }
    it { expect(subject.enum_types.size).to eq(3) }
    it { expect(subject.enum_types.keys).to eq(enum_types)}
  end

  describe '#functions' do
    # TODO add a function definition to metadata
    it { expect(subject).to respond_to(:functions) }
    it { expect(subject.functions.size).to eq(0) }
  end

  describe '#terms' do
    # TBD
  end

  describe '#type_definitions' do
    # TODO add a type definition to metadata
    it { expect(subject).to respond_to(:type_definitions) }
    it { expect(subject.type_definitions.size).to eq(0) }
  end

  describe '#navigation_properties' do
    it { expect(subject).to respond_to(:navigation_properties) }
    it { expect(subject.navigation_properties['Product'].size).to eq(3) }
    it { expect(subject.navigation_properties['Product'].values).to all(be_a(FrOData::NavigationProperty)) }
  end

  describe '#get_property_type' do
    it { expect(subject).to respond_to(:get_property_type) }
    it { expect(subject.get_property_type('Product', 'ID')).to eq('Edm.Int32') }
    it { expect(subject.get_property_type('Product', 'ProductStatus')).to eq('ODataDemo.ProductStatus') }
  end

  describe '#primary_key_for' do
    it { expect(subject).to respond_to(:primary_key_for) }
    it { expect(subject.primary_key_for('Product')).to eq('ID') }
  end

  describe '#properties_for_entity' do
    let(:metadata_file) { 'spec/fixtures/files/metadata_with_error.xml' }
    it { expect(subject).to respond_to(:properties_for_entity) }
    it { expect(subject.properties_for_entity('Product').keys).to eq(%w[
      ID
      Name
      Description
      ReleaseDate
      DiscontinuedDate
      Rating
      Price
      ProductStatus
    ]) }
    it { expect(subject.properties_for_entity('Product').values).to all(be_a(FrOData::Property)) }
    it 'has error message containing type name' do
      expect {
        subject.properties_for_entity('Error')
      }.to raise_error(/Does.Not.Exist/)
    end
  end
end
