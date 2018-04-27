require 'spec_helper'

describe OData4::ServiceRegistry, vcr: {cassette_name: 'service_registry_specs'} do
  let(:subject) { OData4::ServiceRegistry }
  let(:sample_service) { OData4::Service.new('http://services.odata.org/V4/OData/OData.svc', name: 'demoService') }

  it { expect(subject).to respond_to(:add) }
  it { expect(subject).to respond_to(:[]) }

  describe '#add' do
    before(:example) do
      subject.add(sample_service)
    end

    it { expect(subject['demoService']).to eq(sample_service) }
    it { expect(subject['http://services.odata.org/V4/OData/OData.svc']).to eq(sample_service) }
  end
end
