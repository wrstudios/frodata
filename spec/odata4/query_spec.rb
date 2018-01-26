require 'spec_helper'

describe OData4::Query, vcr: {cassette_name: 'query_specs'} do
  before(:example) do
    OData4::Service.open('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo')
  end

  let(:subject) { OData4::Query.new(entity_set) }
  let(:entity_set) { OData4::EntitySet.new(options) }
  let(:options) { {
      container: 'DemoService', namespace: 'ODataDemo', name: 'Products',
      service_name: 'ODataDemo', type: 'Product'
  } }

  it { expect(subject).to respond_to(:to_s) }
  it { expect(subject.to_s).to eq('Products')}

  it { expect(subject).to respond_to(:[]) }
  describe '#[]' do
    it { expect(subject[:Name]).to be_a(OData4::Query::Criteria) }
    it {  expect(subject[:Name].property).to be_a(OData4::Property) }
  end

  it { expect(subject).to respond_to(:find) }
  describe '#find' do
    let(:product) { subject.find(0) }

    it 'finds an entity by its ID' do
      expect(product).to be_a(OData4::Entity)
      expect(product['ID']).to eq(0)
    end

    it 'allows expanding navigational properties' do
      product_with_categories = subject.expand('Categories').find(0)
      expect(product_with_categories['Categories']).to eq([
        { "ID" => 0, "Name" => "Food" }
      ])
    end
  end

  it { expect(subject).to respond_to(:where) }
  describe '#where' do
    let(:criteria) { subject[:Name].eq('Bread') }
    let(:query_string) { "Products?$filter=Name eq 'Bread'" }

    it { expect(subject.where(criteria)).to eq(subject) }
    it { expect(subject.where(criteria).to_s).to eq(query_string) }
  end

  it { expect(subject).to respond_to(:search) }
  describe '#search' do
    let(:term) { '"mountain bike"' }
    let(:query_string) { 'Products?$search="mountain bike"' }

    it { expect(subject.search(term)).to eq(subject) }
    it { expect(subject.search(term).to_s).to eq(query_string) }

    describe 'with multiple terms' do
      let(:query_string) { 'Products?$search="mountain bike" AND NOT clothing' }

      it { expect(subject.search(term).search('NOT clothing').to_s).to eq(query_string) }
    end
  end

  #it { expect(subject).to respond_to(:and) }
  describe '#and' do
    it { pending; fail }
  end

  #it { expect(subject).to respond_to(:or) }
  describe '#or' do
    it { pending; fail }
  end

  it { expect(subject).to respond_to(:skip) }
  describe '#skip' do
    it { expect(subject.skip(5)).to eq(subject) }
    it 'properly formats query with skip specified' do
      subject.skip(5)
      expect(subject.to_s).to eq('Products?$skip=5')
    end
  end

  it { expect(subject).to respond_to(:limit) }
  describe '#limit' do

    it { expect(subject.limit(5)).to eq(subject) }
    it 'properly formats query with limit specified' do
      subject.limit(5)
      expect(subject.to_s).to eq('Products?$top=5')
    end
  end

  it { expect(subject).to respond_to(:include_count) }
  describe '#include_count' do
    it { expect(subject.include_count).to eq(subject) }
    it 'properly formats query with include_count specified' do
      subject.include_count
      expect(subject.to_s).to eq('Products?$count=true')
    end
  end

  it { expect(subject).to respond_to(:select) }
  describe '#select' do
    it { expect(subject.select(:Name, :Price)).to eq(subject) }
    it 'properly formats query with select operation specified' do
      subject.select(:Name, :Price)
      expect(subject.to_s).to eq('Products?$select=Name,Price')
    end
  end

  it { expect(subject).to respond_to(:expand) }
  describe '#expand' do
    it { expect(subject.expand(:Supplier)).to eq(subject) }
    it 'properly formats query with expand operation specified' do
      subject.expand(:Supplier)
      expect(subject.to_s).to eq('Products?$expand=Supplier')
    end
  end

  it { expect(subject).to respond_to(:order_by) }
  describe '#order_by' do
    it { expect(subject.order_by(:Name, :Price)).to eq(subject) }
    it 'properly formats query with orderby operation specified' do
      subject.order_by(:Name, :Price)
      expect(subject.to_s).to eq('Products?$orderby=Name,Price')
    end
  end

  describe '#execute' do
    it { expect(subject).to respond_to(:execute) }
    it { expect(subject.execute).to be_a(OData4::Query::Result) }
  end

  describe '#count' do
    it { expect(subject).to respond_to(:count) }
    it { expect(subject.count).to be_a(Integer) }
    it { expect(subject.count).to eq(11) }

    context 'with filters' do
      let(:criteria) { subject[:Name].eq('Bread') }

      it { expect(subject.where(criteria).count).to eq(1) }
    end
  end

  describe '#empty?' do
    it { expect(subject).to respond_to(:empty?) }
    it { expect(subject.empty?).to eq(false) }

    context 'with filters' do
      let(:non_empty_criteria) { subject[:Name].eq('Bread') }
      let(:empty_criteria) { subject[:Name].eq('NonExistent') }

      it { expect(subject.where(non_empty_criteria).empty?).to eq(false) }
      it { expect(subject.where(empty_criteria).empty?).to eq(true) }
    end
  end

  describe '#in_batches' do
    it { expect(subject).to respond_to(:in_batches) }
    it 'returns OData4::Entities in batches of specified size' do
      batch_count = entity_count = 0

      subject.in_batches(of: 5) do |batch|
        expect(batch).to be_a(OData4::Query::Result)
        expect(batch.count).to eq(5) unless batch_count == 2

        batch.each do |entity|
          expect(entity).to be_a(OData4::Entity)
          expect(entity.type).to eq('Product')
          entity_count += 1
        end

        batch_count += 1
      end

      expect(batch_count).to eq(3)
      expect(entity_count).to eq(11)
    end

    describe '#each' do
      it 'returns OData4::Entities' do
        entity_count = 0

        subject.in_batches(of: 5).each do |entity|
          expect(entity).to be_a(OData4::Entity)
          expect(entity.type).to eq('Product')
          entity_count += 1
        end

        expect(entity_count).to eq(11)
      end
    end
  end
end
