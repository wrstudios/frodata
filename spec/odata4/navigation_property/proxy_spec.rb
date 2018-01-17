require 'spec_helper'

describe OData4::NavigationProperty::Proxy, vcr: {cassette_name: 'navigation_property_proxy_specs'} do
  before :each do
    OData4::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:entity) { OData4::ServiceRegistry['ODataDemo']['Products'][1] }

  let(:categories) { OData4::NavigationProperty::Proxy.new(entity, 'Categories') }
  let(:detail) { OData4::NavigationProperty::Proxy.new(entity, 'ProductDetail') }
  let(:supplier) { OData4::NavigationProperty::Proxy.new(entity, 'Supplier') }

  describe 'value' do
    it { expect(categories.value).to be_a(Enumerable) }
    it { expect(supplier.value).to be_a(OData4::Entity) }
    it { expect(detail.value).to be_a(OData4::Entity) }

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
