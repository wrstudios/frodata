require 'spec_helper'

describe OData::NavigationProperty do
  let(:options) { {
      name: 'Categories',
      type: 'Collection(ODataDemo.Category)',
      partner: 'Products',
  } }
  let(:subject) do
    OData::NavigationProperty.new(options)
  end

  it { expect(subject).to respond_to(:name) }
  it { expect(subject.name).to eq('Categories') }

  it { expect(subject).to respond_to(:type) }
  it { expect(subject.type).to eq('Collection(ODataDemo.Category)') }

  it { expect(subject).to respond_to(:nav_type) }
  it { expect(subject.nav_type).to eq(:collection) }

  it { expect(subject).to respond_to(:nullable) }

  it { expect(subject).to respond_to(:partner) }
  it { expect(subject.partner).to eq('Products') }

  describe '.new' do
    it 'requires name' do
      expect {
        OData::NavigationProperty.new(type: 'Collection(ODataDemo.Category)')
      }.to raise_error(ArgumentError)
    end

    it 'requires type' do
      expect {
        OData::NavigationProperty.new(name: 'Categories')
      }.to raise_error(ArgumentError)
    end
  end

  describe '#build' do
    let(:metadata_file) { File.read 'spec/fixtures/files/v4/metadata.xml' }
    let(:metadata_xml)  { Nokogiri::XML(metadata_file).remove_namespaces! }
    let(:navigation_properties) { metadata_xml.xpath('//NavigationProperty') }
    let(:subject) {
      OData::NavigationProperty.build(navigation_properties.first)
    }

    it { expect(subject.name).to eq('Categories') }
    it { expect(subject.type).to eq('Collection(ODataDemo.Category)') }
    it { expect(subject.partner).to eq('Products') }
    it { expect(subject.nullable).to eq(true) }
    it { expect(subject.nav_type).to eq(:collection) }
  end
end
