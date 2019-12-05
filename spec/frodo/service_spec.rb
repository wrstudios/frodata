require 'spec_helper'

describe Frodo::Service do
  let(:service_url) { 'http://services.odata.org/V4/OData/OData.svc' }
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:subject) { Frodo::Service.new(service_url, name: 'ODataDemo', metadata_file: metadata_file) }

  describe '.new' do
    it 'adds itself to Frodo::ServiceRegistry on creation' do
      expect(Frodo::ServiceRegistry['ODataDemo']).to be_nil
      expect(Frodo::ServiceRegistry[service_url]).to be_nil

      subject

      expect(Frodo::ServiceRegistry['ODataDemo']).to eq(subject)
      expect(Frodo::ServiceRegistry[service_url]).to eq(subject)
    end

    it 'registers custom types on creation' do
      expect(Frodo::PropertyRegistry['ODataDemo.Address']).to be_a(Class)
      expect(Frodo::PropertyRegistry['ODataDemo.ProductStatus']).to be_a(Class)
    end

    it 'allows logger to be set via option' do
      logger = Logger.new(STDERR).tap { |l| l.level = Logger::ERROR }
      service = Frodo::Service.new(service_url,  metadata_file: metadata_file, logger: logger)
      expect(service.logger).to eq(logger)
    end

    context "with complex type referenced by namespace alias" do
      let(:metadata_file) { 'spec/fixtures/files/metadata_dynamics.xml' }
      it 'registers custom types on creation' do
        subject
        expect(Frodo::PropertyRegistry['mscrm.BooleanManagedProperty']).to be_a(Class)
      end
    end
  end

  describe '#logger' do
    let(:subject) { Frodo::Service.new(service_url, name: 'ODataDemo', logger: logger, metadata_file: metadata_file) }
    let(:logger) { Logger.new(STDERR).tap { |l| l.level = Logger::ERROR } }

    it 'returns the logger used by the service' do
      expect(subject.logger).to be_a(Logger)
    end

    it 'returns the default logger if none was set' do
      expect(subject.logger.level).to eq(Logger::ERROR)
    end

    it 'uses Rails logger if available' do
      stub_const 'Rails', Class.new { def self.logger; end }
      allow(Rails).to receive(:logger).and_return(logger)
      expect(subject.logger).to eq(logger)
    end
  end

  describe '#service_url' do
    it { expect(subject).to respond_to(:service_url) }
    it { expect(subject.service_url).to eq(service_url) }
  end

  describe '#schemas' do
    it { expect(subject).to respond_to(:schemas) }
    it { expect(subject.schemas.keys).to eq(['ODataDemo']) }
    it { expect(subject.schemas.values).to all(be_a(Frodo::Schema)) }
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
    it { expect(entity_sets).to all(be_a(Frodo::EntitySet)) }
    it { expect { subject['Nonexistant'] }.to raise_error(ArgumentError) }
    context 'when with_metadata returns false' do
      before { allow(subject).to receive(:with_metadata?).and_return(false) }
      it 'returns  empty EntitySet' do
        expect(subject['Nonexistant']).to be_a(Frodo::EntitySet)
      end
    end
  end

  describe '#with_metadata?' do
    let(:options){{
      name: 'ODataDemo',
      metadata_file: metadata_file
    }}
    let(:subject) { Frodo::Service.new(service_url, options) }

    it { expect(subject.with_metadata?).to be true}

    context "when with_metadata true" do
      let(:options){{
        name: 'ODataDemo',
        metadata_file: metadata_file,
        with_metadata: true
      }}
      it { expect(subject.with_metadata?).to be true}
    end
    context "when with_metadata true" do
      let(:options){{
        name: 'ODataDemo',
        metadata_file: metadata_file,
        with_metadata: true
      }}
      it { expect(subject.with_metadata?).to be true}
    end
  end

  describe '#get_property_type' do
    it { expect(subject).to respond_to(:get_property_type) }
    it { expect(subject.get_property_type('ODataDemo.Product', 'ID')).to eq('Edm.Int32') }
    it { expect(subject.get_property_type('ODataDemo.Product', 'ProductStatus')).to eq('ODataDemo.ProductStatus') }
  end

  describe '#primary_key_for' do
    it { expect(subject).to respond_to(:primary_key_for) }
    it { expect(subject.primary_key_for('ODataDemo.Product')).to eq('ID') }
  end

  describe '#properties_for_entity' do
    it { expect(subject).to respond_to(:properties_for_entity) }
    it { expect(subject.properties_for_entity('ODataDemo.Product').keys).to eq(%w[
      ID
      Name
      Description
      ReleaseDate
      DiscontinuedDate
      Rating
      Price
      ProductStatus
    ]) }
    it { expect(subject.properties_for_entity('ODataDemo.Product').values).to all(be_a(Frodo::Property)) }
  end
end
