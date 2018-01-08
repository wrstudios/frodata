require 'spec_helper'

describe OData::NavigationProperty::Proxy, vcr: {cassette_name: 'v4/NavigationProperty_proxy_specs'} do
  before :each do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData::NavigationProperty::Proxy.new(entity) }
  let(:entity) { OData::ServiceRegistry['ODataDemo']['Products'][1] }

  it { expect(subject).to respond_to(:size)}

  describe '#[]' do
    it { expect(subject).to respond_to(:[]) }
    it { expect(subject['ProductDetail']).to be_a(OData::Entity) }
    it { expect(subject['Categories']).to be_a(Enumerable) }
    it { expect(subject['Categories'].first).to be_a(OData::Entity) }

    context 'when no links exist for an entity' do
      before(:each) do
        expect(entity).to receive(:links) do
          { 'ProductDetail' => nil, 'Categories' => nil }
        end
      end

      context 'for a many NavigationProperty' do
        it { expect(subject['Categories']).to eq([]) }
      end

      context 'for a singular NavigationProperty' do
        it { expect(subject['ProductDetail']).to eq(nil) }
      end
    end
  end
end
