require 'spec_helper'

shared_examples 'a valid response' do
  it { expect(subject).to be_success }
  it { expect(subject.count).to eq(11) }

  describe '#empty?' do
    it { expect(subject).to respond_to(:empty?) }
    it { expect(subject.empty?).to eq(false) }
  end

  describe '#each' do
    it { expect(subject).to respond_to(:each) }
    it 'returns just OData4::Entities of the right type' do
      subject.each do |entity|
        expect(entity).to be_a(OData4::Entity)
        expect(entity.type).to eq('ODataDemo.Product')
      end
    end
  end
end

describe OData4::Service::Response, vcr: {cassette_name: 'service/response_specs'} do
  let(:subject) { OData4::Service::Response.new(service, entity_set.query) { response } }
  let(:service) { OData4::Service.new(service_url, name: 'ODataDemo', metadata_file: metadata_file) }
  let(:service_url) { 'http://services.odata.org/V4/OData/OData.svc' }
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:entity_set) { service['Products'] }
  let(:response) do
    response = double('response')
    allow(response).to receive_messages(
      headers: { 'Content-Type' => content_type },
      status: response_status,
      body: response_body
    )
    response
  end

  context 'with Atom result' do
    let(:content_type) { 'application/atom+xml' }
    let(:response_status) { 200 }
    let(:response_body) { File.read('spec/fixtures/files/products.xml') }

    it_behaves_like 'a valid response'
  end

  context 'with JSON result' do
    let(:content_type) { 'application/json' }
    let(:response_status) { 200 }
    let(:response_body) { File.read('spec/fixtures/files/products.json') }

    it_behaves_like 'a valid response'
  end

  context 'with XML result' do
    let(:content_type) { 'application/xml' }
    let(:response_status) { 200 }
    let(:response_body) { File.read('spec/fixtures/files/error.xml') }

    it 'contains no entities' do
      expect(subject.empty?).to eq(true)
    end

    it 'contains error message' do
      expect(subject.error_message).to match(/Resource not found/)
    end
  end

  context 'with plain text result' do
    let(:content_type) { 'text/plain' }
    let(:response_status) { 200 }
    let(:response_body) { '123' }

    it { expect(subject).to be_success }
    it { expect(subject.body).to match(/123/) }
  end
end
