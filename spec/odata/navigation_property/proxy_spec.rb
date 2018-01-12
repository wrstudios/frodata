require 'spec_helper'

describe OData::NavigationProperty::Proxy, vcr: {cassette_name: 'NavigationProperty_proxy_specs'} do
  before :each do
    OData::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:entity) { OData::ServiceRegistry['ODataDemo']['Products'][1] }

  let(:categories) { OData::NavigationProperty::Proxy.new(entity, 'Categories') }
  let(:detail) { OData::NavigationProperty::Proxy.new(entity, 'ProductDetail') }
  let(:supplier) { OData::NavigationProperty::Proxy.new(entity, 'Supplier') }

  describe 'value' do
    it { expect(categories.value).to be_a(Enumerable) }
    it { expect(supplier.value).to be_a(OData::Entity) }
    it { expect(detail.value).to be_a(OData::Entity) }

    context 'when no links exist for an entity' do
      before(:each) do
        expect(entity).to receive(:links) do
          { 'Categories' => nil, 'Supplier' => nil }
        end
      end

      context 'for a many NavigationProperty' do
        it { expect(categories.value).to eq([]) }
      end

      context 'for a singular NavigationProperty' do
        it { expect(supplier.value).to eq(nil) }
      end
    end
  end
end
