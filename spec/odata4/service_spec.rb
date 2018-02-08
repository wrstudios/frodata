require 'spec_helper'

describe OData4::Service, vcr: {cassette_name: 'service_specs'} do
  let(:service_url) { 'http://services.odata.org/V4/OData/OData.svc' }
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:subject) { OData4::Service.open(service_url, name: 'ODataDemo', metadata_file: metadata_file) }
  let(:entity_types) { %w{Product FeaturedProduct ProductDetail Category Supplier Person Customer Employee PersonDetail Advertisement} }
  let(:entity_sets) { %w{Products ProductDetails Categories Suppliers Persons PersonDetails Advertisements} }
  let(:entity_set_types) { %w{Product ProductDetail Category Supplier Person PersonDetail Advertisement} }
  let(:complex_types) { %w{Address} }
  let(:enum_types) { %w{ProductStatus} }

  describe '.open' do
    it { expect(OData4::Service).to respond_to(:open) }
  end

  it 'adds itself to OData4::ServiceRegistry on creation' do
    expect(OData4::ServiceRegistry['ODataDemo']).to be_nil
    expect(OData4::ServiceRegistry[service_url]).to be_nil

    service = OData4::Service.open(service_url, name: 'ODataDemo')

    expect(OData4::ServiceRegistry['ODataDemo']).to eq(service)
    expect(OData4::ServiceRegistry[service_url]).to eq(service)
  end

  describe 'instance methods' do
    it { expect(subject).to respond_to(:service_url) }
    it { expect(subject).to respond_to(:entity_types) }
    it { expect(subject).to respond_to(:entity_sets) }
    it { expect(subject).to respond_to(:complex_types) }
    it { expect(subject).to respond_to(:enum_types) }
    it { expect(subject).to respond_to(:namespace) }
  end

  describe '#service_url' do
    it { expect(subject.service_url).to eq(service_url) }
  end

  describe '#entity_types' do
    it { expect(subject.entity_types.size).to eq(10) }
    it { expect(subject.entity_types).to eq(entity_types) }
  end

  describe '#entity_sets' do
    it { expect(subject.entity_sets.size).to eq(7) }
    it { expect(subject.entity_sets.keys).to eq(entity_set_types) }
    it { expect(subject.entity_sets.values).to eq(entity_sets) }
  end

  describe '#complex_types' do
    it { expect(subject.complex_types.size).to eq(1) }
    it { expect(subject.complex_types.keys).to eq(complex_types) }
  end

  describe '#enum_types' do
    it { expect(subject.enum_types.size).to eq(1) }
    it { expect(subject.enum_types.keys).to eq(enum_types)}
  end

  describe '#navigation_properties' do
    it { expect(subject).to respond_to(:navigation_properties) }
    it { expect(subject.navigation_properties['Product'].size).to eq(3) }
    it { expect(subject.navigation_properties['Product']['Categories']).to be_a(OData4::NavigationProperty) }
  end

  describe '#namespace' do
    it { expect(subject.namespace).to eq('ODataDemo') }
  end

  describe '#[]' do
    it { expect(subject['Products']).to be_a(OData4::EntitySet) }
    it { expect {subject['Nonexistant']}.to raise_error(ArgumentError) }
  end
end
