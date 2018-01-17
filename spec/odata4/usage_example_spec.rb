require 'spec_helper'

describe 'Usage examples', vcr: { cassette_name: 'usage_example_specs' } do
  let(:service_url) { 'http://services.odata.org/V4/OData/OData.svc' }
  let(:service) { OData4::Service.open(service_url, name: 'ODataDemo') }

  describe 'getting information' do
    it 'returns the service URL' do
      expect(service.service_url).to eq(service_url)
    end

    it 'returns the service namespace' do
      expect(service.namespace).to eq('ODataDemo')
    end

    it 'lists entity types' do
      expect(service.entity_types).to eq([
        "Product",
        "FeaturedProduct",
        "ProductDetail",
        "Category",
        "Supplier",
        "Person",
        "Customer",
        "Employee",
        "PersonDetail",
        "Advertisement"
      ])
    end

    it 'lists entity sets' do
      expect(service.entity_sets).to eq({
        "Product"       => "Products",
        "ProductDetail" => "ProductDetails",
        "Category"      => "Categories",
        "Supplier"      => "Suppliers",
        "Person"        => "Persons",
        "PersonDetail"  => "PersonDetails",
        "Advertisement" => "Advertisements"
      })
    end
  end

  describe 'working with entity sets' do
    it 'accessing entity sets' do
      service.entity_sets.each do |entity_name, set_name|
        entity_set = service[set_name]

        expect(entity_set).to be_a(OData4::EntitySet)
        expect(entity_set.name).to eq(set_name)
        expect(entity_set.type).to eq(entity_name)
        expect(entity_set.namespace).to eq(service.namespace)
      end
    end

    describe 'accessing entities' do
      let(:products) { service['Products'] }

      it 'getting the first entity in a set' do
        expect(products.first).to be_a(OData4::Entity)
        expect(products.first.name).to eq('Product')
      end

      it 'iterating over the entire set' do
        products.each do |product|
          expect(product).to be_a(OData4::Entity)
          expect(product.name).to eq('Product')
        end
      end

      it 'counting entities' do
        expect(products.count).to eq(11)
      end

      it 'creating a new entity' do
        new_product = products.new_entity

        expect(new_product).to be_a(OData4::Entity)
        expect(new_product.name).to eq('Product')
      end
    end

    describe 'querying' do
      let(:products) { service['Products'] }
      let(:query)    { products.query }

      it 'obtain a query object using #query' do
        expect(products.query).to be_a(OData4::Query)
      end

      it 'executing query' do
        results = query.execute

        expect(results.map { |p| p['Name']}).to eq([
          "Bread",
          "Milk",
          "Vint soda",
          "Havina Cola",
          "Fruit Punch",
          "Cranberry Juice",
          "Pink Lemonade",
          "DVD Player",
          "LCD HDTV",
          "Lemonade",
          "Coffee"
        ])
      end

      it 'adding criteria' do
        query.where(query['Name'].eq('Milk'))
        results = query.execute

        expect(query.to_s).to eq("Products?$filter=Name eq 'Milk'")
        results.each do |product|
          expect(product).to be_a(OData4::Entity)
          expect(product.name).to eq('Product')
          expect(product['Name']).to eq('Milk')
        end
      end

      it 'ordering results' do
        results = query.order_by('Name').execute

        expect(results.map { |p| p['Name'] }).to eq([
          "Bread",
          "Coffee",
          "Cranberry Juice",
          "DVD Player",
          "Fruit Punch",
          "Havina Cola",
          "LCD HDTV",
          "Lemonade",
          "Milk",
          "Pink Lemonade",
          "Vint soda"
        ])
      end

      it 'returning query results in batches' do
        batch_count = 0

        query.in_batches(of: 5) do |batch|
          expect(batch.count).to eq(5) unless batch_count == 2

          batch.each do |entity|
            expect(entity).to be_a(OData4::Entity)
            expect(entity.type).to eq('Product')
          end
          batch_count += 1
        end

        expect(batch_count).to eq(3)
      end
    end
  end

  describe 'working with entities' do
    let(:product) { service['Products'][1] }

    it 'getting a list of property names' do
      expect(product.property_names).to eq([
        "ID", "Name", "Description", "ReleaseDate", "DiscontinuedDate", "Rating", "Price"
      ])
    end

    it 'accessing entity properties' do
      expect(product["ID"]).to eq(1)
      expect(product["Name"]).to eq("Milk")
      expect(product["Description"]).to eq("Low fat milk")
      expect(product["ReleaseDate"]).to eq(DateTime.parse("1995-10-01T00:00:00Z"))
      expect(product["DiscontinuedDate"]).to be_nil
      expect(product["Rating"]).to eq(3)
      expect(product["Price"]).to eq(3.5)
    end
  end
end
