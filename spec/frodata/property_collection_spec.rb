require 'spec_helper'

describe FrOData::Property do
  let(:service) do
    FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', metadata_file: metadata_file)
  end
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }

  describe '#type' do
    it 'returns the right type' do
      t = service.schemas['ODataDemo'].properties_for_entity('Product')['ProductStatus'].type
      expect(t).to eq('ODataDemo.ProductStatus')

      t = service.schemas['ODataDemo'].properties_for_entity('Product')['EthicalAttributes'].type
      expect(t).to eq('Collection(ODataDemo.EthicalAttribute)')
    end
  end
end
