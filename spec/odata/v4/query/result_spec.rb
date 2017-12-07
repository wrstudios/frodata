require 'spec_helper'

describe OData::Query::Result, vcr: {cassette_name: 'v4/query/result_specs'} do
  before(:example) do
    OData::Service.open('http://services.odata.org/OData/OData.svc', name: 'ODataDemo')
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
end
