require 'spec_helper'

describe OData::Query::Result, vcr: {cassette_name: 'v4/query/result_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { entity_set.query.execute }
  let(:entity_set) { OData::ServiceRegistry['ODataDemo']['Products'] }

  it { expect(subject).to respond_to(:each) }
  describe '#each' do
    it 'returns just OData::Entities of the right type' do
      subject.each do |entity|
        expect(entity).to be_a(OData::Entity)
        expect(entity.type).to eq('Product')
      end
    end
  end

  describe 'automatic content detection' do
    let(:result) { OData::Query::Result.new(entity_set.query, response) }
    let(:response) do
      response = double('response')
      allow(response).to receive_messages(
        headers: { 'Content-Type' => content_type },
        body: response_body
      )
      response
    end

    context 'with Atom Result' do
      let(:content_type) { 'application/atom+xml' }
      let(:response_body) { File.read('spec/fixtures/files/v4/products.xml') }

      it { expect(result.count).to eq(11) }
      it 'correctly parses entities' do
        result.each do |entity|
          expect(entity).to be_a(OData::Entity)
          expect(entity.type).to eq('Product')
        end
      end
    end

    context 'with JSON Result' do
      let(:content_type) { 'application/json' }
      let(:response_body) { File.read('spec/fixtures/files/v4/products.json') }

      it { expect(result.count).to eq(11) }
      it 'correctly parses entities' do
        result.each do |entity|
          expect(entity).to be_a(OData::Entity)
          expect(entity.type).to eq('Product')
        end
      end
    end
  end
end
