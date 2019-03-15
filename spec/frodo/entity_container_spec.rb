require 'spec_helper'

describe Frodo::EntityContainer do
  let(:subject) { Frodo::EntityContainer.new(service) }
  let(:service) do
    Frodo::Service.new('http://services.odata.org/V4/OData/OData.svc', metadata_file: metadata_file)
  end
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }

  describe '#entity_sets' do
    it { expect(subject).to respond_to(:entity_sets) }
    it { expect(subject.entity_sets.size).to eq(7) }
    it { expect(subject.entity_sets.keys).to eq(%w[
      Products
      ProductDetails
      Categories
      Suppliers
      Persons
      PersonDetails
      Advertisements
    ]) }
    it { expect(subject.entity_sets.values).to eq(%w[
      ODataDemo.Product
      ODataDemo.ProductDetail
      ODataDemo.Category
      ODataDemo.Supplier
      ODataDemo.Person
      ODataDemo.PersonDetail
      ODataDemo.Advertisement
    ]) }
  end

  describe '#[]' do
    let(:entity_sets) { subject.entity_sets.keys.map { |name| subject[name] } }
    it { expect(entity_sets).to all(be_a(Frodo::EntitySet)) }
    it { expect {subject['Nonexistant']}.to raise_error(ArgumentError) }
  end
end
