require 'spec_helper'

shared_examples 'valid result' do
  it { expect(result.count).to eq(11) }

  describe '#empty?' do
    it { expect(result).to respond_to(:empty?) }
    it { expect(result.empty?).to eq(false) }
  end

  describe '#each' do
    it { expect(result).to respond_to(:each) }
    it 'returns just OData4::Entities of the right type' do
      result.each do |entity|
        expect(entity).to be_a(OData4::Entity)
        expect(entity.type).to eq('Product')
      end
    end
  end
end

describe OData4::Query::Result, vcr: {cassette_name: 'query/result_specs'} do
  before(:example) do
    OData4::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:entity_set) { OData4::ServiceRegistry['ODataDemo']['Products'] }
  # let(:subject) { entity_set.query.execute }

  let(:response) do
    response = double('response')
    allow(response).to receive_messages(
      headers: { 'Content-Type' => content_type },
      body: response_body
    )
    response
  end
  let(:result) { OData4::Query::Result.new(entity_set.query, response) }

  context 'with Atom Result' do
    let(:content_type) { 'application/atom+xml' }
    let(:response_body) { File.read('spec/fixtures/files/products.xml') }

    it_behaves_like 'valid result'
  end

  context 'with JSON Result' do
    let(:content_type) { 'application/json' }
    let(:response_body) { File.read('spec/fixtures/files/products.json') }

    it_behaves_like 'valid result'
  end
end
