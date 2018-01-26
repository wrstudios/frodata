require 'spec_helper'

describe OData4::NavigationProperty::Proxy, vcr: {cassette_name: 'navigation_property_proxy_specs'} do
  before :each do
    OData4::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:entity) { OData4::ServiceRegistry['ODataDemo']['Products'][1] }

  let(:categories_proxy) { OData4::NavigationProperty::Proxy.new(entity, 'Categories') }
  let(:detail_proxy) { OData4::NavigationProperty::Proxy.new(entity, 'ProductDetail') }
  let(:supplier_proxy) { OData4::NavigationProperty::Proxy.new(entity, 'Supplier') }

  describe 'value' do
    it { expect(categories_proxy.value).to be_a(Enumerable) }
    it { expect(supplier_proxy.value).to be_a(OData4::Entity) }
    it { expect(detail_proxy.value).to be_a(OData4::Entity) }

    context 'when value was explicitly set' do
      let(:supplier) { double('supplier') }

      it 'returns the set value' do
        supplier_proxy.value = supplier
        expect(supplier_proxy.value).to eq(supplier)
      end
    end

    context 'when no links exist for an entity' do
      before(:each) do
        expect(entity).to receive(:links) do
          { 'Categories' => nil, 'Supplier' => nil }
        end
      end

      context 'for a many NavigationProperty' do
        it { expect(categories_proxy.value).to eq([]) }
      end

      context 'for a singular NavigationProperty' do
        it { expect(supplier_proxy.value).to eq(nil) }
      end
    end
  end
end
