require 'spec_helper'

describe OData4::Service, vcr: {cassette_name: 'service_specs'} do
  let(:service_url) { 'http://services.odata.org/V4/OData/OData.svc' }
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:subject) { OData4::Service.open(service_url, name: 'ODataDemo', metadata_file: metadata_file) }

  describe '.open' do
    it { expect(OData4::Service).to respond_to(:open) }
    it 'adds itself to OData4::ServiceRegistry on creation' do
      expect(OData4::ServiceRegistry['ODataDemo']).to be_nil
      expect(OData4::ServiceRegistry[service_url]).to be_nil

      service = OData4::Service.open(service_url, name: 'ODataDemo')

      expect(OData4::ServiceRegistry['ODataDemo']).to eq(service)
      expect(OData4::ServiceRegistry[service_url]).to eq(service)
    end
    it 'registers custom types on creation' do
      service = OData4::Service.open(service_url, name: 'ODataDemo')

      expect(OData4::PropertyRegistry['ODataDemo.Address']).to be_a(Class)
      expect(OData4::PropertyRegistry['ODataDemo.ProductStatus']).to be_a(Class)
    end
  end

  describe '#service_url' do
    it { expect(subject).to respond_to(:service_url) }
    it { expect(subject.service_url).to eq(service_url) }
  end

  describe '#schemas' do
    it { expect(subject).to respond_to(:schemas) }
    it { expect(subject.schemas.keys).to eq(['ODataDemo']) }
    it { expect(subject.schemas.values).to all(be_a(OData4::Schema)) }
    it {
      subject.schemas.each do |namespace, schema|
        expect(schema.namespace).to eq(namespace)
      end
    }
  end

  describe '#entity_types' do
    it { expect(subject).to respond_to(:entity_types) }
    it { expect(subject.entity_types.size).to eq(10) }
    it { expect(subject.entity_types).to eq(%w[
      ODataDemo.Product
      ODataDemo.FeaturedProduct
      ODataDemo.ProductDetail
      ODataDemo.Category
      ODataDemo.Supplier
      ODataDemo.Person
      ODataDemo.Customer
      ODataDemo.Employee
      ODataDemo.PersonDetail
      ODataDemo.Advertisement
    ]) }
  end

  describe '#entity_sets' do
    it { expect(subject).to respond_to(:entity_sets) }
    it { expect(subject.entity_sets.size).to eq(7) }
    it { expect(subject.entity_sets.keys).to eq(%w[
      Products
      ProductDetails
      Categories
      Suppliers
      Persons
      PersonDetails
      Advertisements
    ]) }
    it { expect(subject.entity_sets.values).to eq(%w[
      ODataDemo.Product
      ODataDemo.ProductDetail
      ODataDemo.Category
      ODataDemo.Supplier
      ODataDemo.Person
      ODataDemo.PersonDetail
      ODataDemo.Advertisement
    ]) }
  end

  describe '#complex_types' do
    it { expect(subject).to respond_to(:complex_types) }
    it { expect(subject.complex_types.size).to eq(1) }
    it { expect(subject.complex_types.keys).to eq(['ODataDemo.Address']) }
  end

  describe '#enum_types' do
    it { expect(subject).to respond_to(:enum_types) }
    it { expect(subject.enum_types.size).to eq(1) }
    it { expect(subject.enum_types.keys).to eq(['ODataDemo.ProductStatus'])}
  end

  describe '#namespace' do
    it { expect(subject.namespace).to eq('ODataDemo') }
  end

  describe '#[]' do
    let(:entity_sets) { subject.entity_sets.keys.map { |name| subject[name] } }
    it { expect(entity_sets).to all(be_a(OData4::EntitySet)) }
    it { expect {subject['Nonexistant']}.to raise_error(ArgumentError) }
  end
end
