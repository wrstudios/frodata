require 'spec_helper'
require_relative 'entity/shared_examples'

describe Frodo::Entity, vcr: false do
  before(:example) do
    Frodo::Service.new('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo', metadata_file: metadata_file)
  end

  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:subject) { Frodo::Entity.new(options) }
  let(:options) { {
      type:         'ODataDemo.Product',
      namespace:    'ODataDemo',
      service_name: 'ODataDemo'
  } }

  it { expect(subject).to respond_to(:name, :type, :namespace, :service_name) }

  it { expect(subject.name).to eq('Product') }
  it { expect(subject.type).to eq('ODataDemo.Product') }
  it { expect(subject.namespace).to eq('ODataDemo') }
  it { expect(subject.service_name).to eq('ODataDemo') }

  describe '.with_properties' do
    let(:subject) { Frodo::Entity.with_properties(properties, options) }
    let(:properties) { {
      "ID"               => 0,
      "Name"             => "Bread",
      "Description"      => "Whole grain bread",
      "ReleaseDate"      => "1992-01-01T00:00:00Z",
      "DiscontinuedDate" => nil,
      "Rating"           => 4,
      "Price"            => 2.5
    } }
    let(:entity_set) {
      Frodo::EntitySet.new(
        container: 'DemoService',
        namespace: 'ODataDemo',
        name: 'Products',
        type: 'Product',
        service_name: 'ODataDemo')
    }
    let(:options) { {
        type:         'ODataDemo.Product',
        namespace:    'ODataDemo',
        service_name: 'ODataDemo',
        entity_set:   entity_set
    } }

    it_behaves_like 'a valid product'
  end

  describe '.with_properties with bind properties' do
    before do
      Frodo::Service.new('http://dynamics.com', name: 'DynamicsTestService', metadata_file: metadata_file)
    end
    let(:metadata_file) { 'spec/fixtures/files/metadata_dynamics.xml' }
    let(:subject) { Frodo::Entity.with_properties(properties, options) }
    let(:properties) { {
      "firstname"                => "Christoph",
      "lastname"                 => "Wagner",
      "ownerid@odata.bind"                  => "/systemusers(95B9F1A8-3D5A-E911-A956-000D3A3B9CD8)",
      "parentcustomerid_account@odata.bind" => "/accounts(60fb3f1c-b766-e911-a955-000d3a3b9316)",
    } }
    let(:entity_set) {
      Frodo::EntitySet.new(
        container: 'System',
        namespace: 'Microsoft.Dynamics.CRM',
        name: 'contacts',
        type: 'contact',
        service_name: 'DynamicsTestService')
    }
    let(:options) { {
        type:         'Microsoft.Dynamics.CRM.contact',
        namespace:    'Microsoft.Dynamics.CRM',
        service_name: 'DynamicsTestService',
        entity_set:   entity_set
    } }

    it do
      aggregate_failures do
        expect(subject).to be_a(Frodo::Entity)

        expect(subject.name).to eq(entity_set.type)
        expect(subject.type).to eq(options[:type])
        expect(subject.namespace).to eq(options[:namespace])
        expect(subject.service_name).to eq('DynamicsTestService')
        expect(subject.context).to eq('http://dynamics.com/$metadata#contacts/$entity')
        expect(subject.id).to eq('contacts()')
        expect(subject['firstname']).to eq('Christoph')
        expect(subject['lastname']).to eq('Wagner')
        expect(subject['ownerid']).to eq('/systemusers(95B9F1A8-3D5A-E911-A956-000D3A3B9CD8)')
        expect(subject['parentcustomerid_account']).to eq('/accounts(60fb3f1c-b766-e911-a955-000d3a3b9316)')
      end
    end
  end

  describe '.from_xml' do
    let(:subject) { Frodo::Entity.from_xml(product_xml, options) }
    let(:product_xml) {
      document = ::Nokogiri::XML(File.open('spec/fixtures/files/product_0.xml'))
      document.remove_namespaces!
      document.xpath('//entry').first
    }

    it { expect(Frodo::Entity).to respond_to(:from_xml) }

    it_behaves_like 'a valid product'

    context 'with a complex type property' do
      let(:options) { {
          type:         'ODataDemo.Supplier',
          namespace:    'ODataDemo',
          service_name: 'ODataDemo'
      } }

      let(:subject) { Frodo::Entity.from_xml(supplier_xml, options) }
      let(:supplier_xml) {
        document = ::Nokogiri::XML(File.open('spec/fixtures/files/supplier_0.xml'))
        document.remove_namespaces!
        document.xpath('//entry').first
      }

      it_behaves_like 'a valid supplier'
    end
  end

  describe '#to_xml' do
    let(:subject) { Frodo::Entity.with_properties(properties, options) }
    let(:properties) { {
      "ID"               => 0,
      "Name"             => "Bread",
      "Description"      => "Whole grain bread",
      "ReleaseDate"      => "1992-01-01T00:00:00Z",
      "DiscontinuedDate" => nil,
      "Rating"           => 4,
      "Price"            => 2.5
    } }
    let(:options) { {
        type:         'ODataDemo.Product',
        namespace:    'ODataDemo',
        service_name: 'ODataDemo'
    } }
    let(:product_xml) {
      File.read('spec/fixtures/files/entity_to_xml.xml')
    }

    # TODO: parse the XML and veryify property values instead?
    # TODO: explicitly assert namespace URIs?
    it { expect(subject.to_xml).to eq(product_xml) }
  end

  describe '.from_json' do
    let(:subject) { Frodo::Entity.from_json(product_json, options) }
    let(:product_json) {
      File.read('spec/fixtures/files/product_0.json')
    }

    it { expect(Frodo::Entity).to respond_to(:from_json) }
    it_behaves_like 'a valid product'

    context 'with a complex type property' do
      let(:options) { {
          type:         'ODataDemo.Supplier',
          namespace:    'ODataDemo',
          service_name: 'ODataDemo'
      } }

      let(:subject) { Frodo::Entity.from_json(supplier_json, options) }
      let(:supplier_json) {
        File.read('spec/fixtures/files/supplier_0.json')
      }

      it_behaves_like 'a valid supplier'
    end
  end

  describe '#to_json' do
    let(:subject) { Frodo::Entity.with_properties(properties, options) }
    let(:properties) { {
      "ID"               => 0,
      "Name"             => "Bread",
      "Description"      => "Whole grain bread",
      "ReleaseDate"      => "1992-01-01T00:00:00Z",
      "DiscontinuedDate" => nil,
      "Rating"           => 4,
      "Price"            => 2.5,
      "ProductStatus"    => nil
    } }
    let(:options) { {
        type:         'ODataDemo.Product',
        namespace:    'ODataDemo',
        service_name: 'ODataDemo'
    } }

    it { expect(subject.to_json).to eq(properties.to_json) }
  end
end
