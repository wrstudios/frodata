require 'spec_helper'

describe OData::Entity, vcr: {cassette_name: 'v4/entity_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::Entity.new(options) }
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

  describe '#links' do
    let(:subject) { OData::Entity.from_xml(product_xml, options) }
    let(:product_xml) {
      document = ::Nokogiri::XML(File.open('spec/fixtures/sample_service/v4/product_0.xml'))
      document.remove_namespaces!
      document.xpath('//entry').first
    }
    let(:links) do
      {
          'Categories'    => {type: :feed, href: 'Products(0)/Categories'},
          'Supplier'      => {type: :entry, href: 'Products(0)/Supplier'},
          'ProductDetail' => {type: :entry, href: 'Products(0)/ProductDetail'}
      }
    end

    it { expect(subject).to respond_to(:links) }
    it { expect(subject.links.size).to eq(3) }
    it { expect(subject.links).to eq(links) }
  end

  describe '#associations' do
    it { expect(subject).to respond_to(:associations) }
    it { expect(subject.associations.size).to eq(3) }
    it { expect {subject.associations['NonExistant']}.to raise_error(ArgumentError) }
  end

  describe '.with_properties' do
    let(:subject) { OData::Entity.with_properties(properties, options) }
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

    # Check property types
    it { expect(subject.get_property('ID')).to be_a(OData::Properties::Integer) }
    it { expect(subject.get_property('Name')).to be_a(OData::Properties::String) }
    it { expect(subject.get_property('Description')).to be_a(OData::Properties::String) }
    it { expect(subject.get_property('ReleaseDate')).to be_a(OData::Properties::DateTimeOffset) }
    it { expect(subject.get_property('DiscontinuedDate')).to be_a(OData::Properties::DateTimeOffset) }
    it { expect(subject.get_property('Rating')).to be_a(OData::Properties::Integer) }
    it { expect(subject.get_property('Price')).to be_a(OData::Properties::Double) }

    # Check property values
    it { expect(subject['ID']).to eq(0) }
    it { expect(subject['Name']).to eq('Bread') }
    it { expect(subject['Description']).to eq('Whole grain bread') }
    it { expect(subject['ReleaseDate']).to eq(DateTime.parse('1992-01-01T00:00:00Z')) }
    it { expect(subject['DiscontinuedDate']).to eq(nil) }
    it { expect(subject['Rating']).to eq(4) }
    it { expect(subject['Price']).to eq(2.5) }
  end

  describe '.from_xml' do
    let(:subject) { OData::Entity.from_xml(product_xml, options) }
    let(:product_xml) {
      document = ::Nokogiri::XML(File.open('spec/fixtures/sample_service/v4/product_0.xml'))
      document.remove_namespaces!
      document.xpath('//entry').first
    }

    it { expect(OData::Entity).to respond_to(:from_xml) }
    it { expect(subject).to be_a(OData::Entity) }

    it { expect(subject.name).to eq('Product') }
    it { expect(subject.type).to eq('ODataDemo.Product') }
    it { expect(subject.namespace).to eq('ODataDemo') }
    it { expect(subject.service_name).to eq('ODataDemo') }

    it { expect(subject['ID']).to eq(0) }
    it { expect(subject['Name']).to eq('Bread') }
    it { expect(subject['Description']).to eq('Whole grain bread') }
    it { expect(subject['ReleaseDate']).to eq(DateTime.new(1992,1,1,0,0,0,0)) }
    it { expect(subject['DiscontinuedDate']).to be_nil }
    it { expect(subject['Rating']).to eq(4) }
    it { expect(subject['Price']).to eq(2.5) }

    it { expect {subject['NonExistant']}.to raise_error(ArgumentError) }
    it { expect {subject['NonExistant'] = 5}.to raise_error(ArgumentError) }

    context 'with a complex type property' do
      let(:options) { {
          type:         'ODataDemo.Supplier',
          namespace:    'ODataDemo',
          service_name: 'ODataDemo'
      } }

      let(:subject) { OData::Entity.from_xml(supplier_xml, options) }
      let(:supplier_xml) {
        document = ::Nokogiri::XML(File.open('spec/fixtures/sample_service/v4/supplier_0.xml'))
        document.remove_namespaces!
        document.xpath('//entry').first
      }

      it { expect(subject.name).to eq('Supplier') }
      it { expect(subject.type).to eq('ODataDemo.Supplier') }

      it { expect(subject['Address']).to be_a(OData::ComplexType::Property) }
      it { expect(subject['Address'][ 'Street']).to eq('NE 228th') }
      it { expect(subject['Address'][   'City']).to eq('Sammamish') }
      it { expect(subject['Address'][  'State']).to eq('WA') }
      it { expect(subject['Address']['ZipCode']).to eq('98074') }
      it { expect(subject['Address']['Country']).to eq('USA') }
    end
  end

  describe '.to_xml' do
    let(:subject) { OData::Entity.with_properties(properties, options) }
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
      <<-END
      <?xml version="1.0"?>
      <entry xmlns="http://www.w3.org/2005/Atom" xmlns:data="http://docs.oasis-open.org/odata/ns/data" xmlns:metadata="http://docs.oasis-open.org/odata/ns/metadata" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml" xml:base="http://services.odata.org/V4/OData/OData.svc">
        <category term="ODataDemo.ODataDemo.Product" scheme="http://docs.oasis-open.org/odata/ns/scheme"/>
        <author>
          <name/>
        </author>
        <content type="application/xml">
          <metadata:properties>
            <data:Name metadata:type="Edm.String">Bread</data:Name>
            <data:Description metadata:type="Edm.String">Whole grain bread</data:Description>
            <data:ReleaseDate metadata:type="Edm.DateTimeOffset">1992-01-01T00:00:00+00:00</data:ReleaseDate>
            <data:DiscontinuedDate metadata:type="Edm.DateTimeOffset" metadata:null="true"/>
            <data:Rating metadata:type="Edm.Int16">4</data:Rating>
            <data:Price metadata:type="Edm.Double">2.5</data:Price>
          </metadata:properties>
        </content>
      </entry>
      END
      .gsub(/^\s{6}/, '')
    }

    # TODO: perhaps it's better to parse the XML and veryify property values instead?
    # TODO: explicitly assert namespace URIs?
    it { expect(subject.to_xml).to eq(product_xml) }
  end
end
