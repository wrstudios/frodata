# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe Frodo::Concerns::API do
  let(:klass) do
    context = self
    Class.new do
      include Frodo::Concerns::Base
      include Frodo::Concerns::Connection

      include context.described_class
    end
  end

  let(:client) { klass.new }
  let(:connection_uri) { 'http://frodo.com' }
  let(:connection) do
    Faraday.new(connection_uri, {}) do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
    end
  end

  subject { client }

  let(:id) { 'some-id' }
  let(:body) { 'Body' }
  let(:path) { 'something/foo' }
  # Leverage WebMock match URI by pattern, needs to escape string otherwise chars like '$' are misinterpretted
  let(:uri) { /#{Regexp.escape(path)}/ }
  let(:options) { {} }
  let(:verb) { :get }
  let(:headers) { {} }
  let(:entity_type) { 'Type' }
  let(:entity_set) { double(Frodo::EntitySet) }
  let(:entity) { double(Frodo::Entity) }
  let(:service) { double(Frodo::Service) }
  let(:query) { double(Frodo::Query) }
  let(:client_error) { Faraday::Error::ClientError.new(StandardError.new) }

  before do
    stub_request(verb, uri).to_return(body: body.to_json, headers: headers)
    allow(client).to receive(:options).and_return(options)
    allow(client).to receive(:connection).and_return(connection)
  end

  describe '.metadata' do
    let(:path) { '$metadata' }

    it 'fetches body of GET $metadata' do
      expect(subject.metadata).to eq(body)
    end
  end

  describe '.query' do
    let(:url_chunk) { "leads?$filter=firstname eq 'yo'" }
    let(:path) { url_chunk }
    let(:entity_name) { 'entity' }
    let(:context) { "serviceRoot/$metadata##{entity_name}" }
    let(:body) { { '@odata.context' => context } }

    context 'url_chunk provided' do
      let(:query) { url_chunk }

      it 'returns entity fetched from url_chunk' do
        allow(client).to receive(:build_entity).with(entity_name, body).and_return(entity)

        expect(subject.query(query)).to eq(entity)
      end
    end

    context 'Frodo::Query provided' do
      let(:query) { double(Frodo::Query) }

      it 'returns entity fetched from query' do
        allow(query).to receive(:to_s).and_return(path)
        allow(query).to receive(:entity_set).and_return(entity)
        allow(entity).to receive(:name).and_return(entity_name)
        allow(client).to receive(:build_entity).with(entity_name, body).and_return(entity)

        expect(subject.query(query)).to eq(entity)
      end
    end
  end

  describe '.create' do
    let(:attributes) { {} }

    subject { client.create(entity_type, attributes) }

    it 'calls .create! and returns the result' do
      allow(client).to receive(:create!).with(entity_type, attributes).and_return(true)

      expect(subject).to eq(true)
    end

    it 'returns false for expected exceptions' do
      allow(client).to receive(:create!).with(entity_type, attributes).and_raise(client_error)

      expect(subject).to eq(false)
    end

    it 'raises other errors' do
      allow(client).to receive(:create!).with(entity_type, attributes).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end
  end

  describe '.create!' do
    let(:id) { 'an-id' }
    let(:url) { "blah/(#{id})/foo" }
    let(:verb) { :post }
    let(:attributes) { {} }
    let(:options) { attributes }
    let(:headers) { { 'odata-entityid' => url } }

    before { stub_request(verb, "#{connection_uri}/#{entity_type}").to_return(body: body.to_json, headers: headers) }
    subject { client.create!(entity_type, attributes) }

    it 'posts entity_set info and returns resulting id' do
      expect(subject).to eq(id)
    end

    context 'alias .insert!' do
      subject { client.insert!(entity_type, attributes) }

      it { should eq(id) }
    end
  end

  describe '.update' do
    let(:attributes) { { 'typeid' => 'some_id' } }
    let(:primary_key) { 'typeid' }

    before { stub_request(verb, "#{connection_uri}/#{entity_type}(some_id)").to_return(body: body.to_json, headers: headers) }
    subject { client.update(entity_type, primary_key, attributes) }

    it 'calls .create! and returns the result' do
      expect(client).to receive(:update!).with(entity_type, primary_key, attributes).and_return(true)

      expect(subject).to be(true)
    end

    it 'returns false for expected exceptions' do
      allow(client).to receive(:update!).with(entity_type, primary_key, attributes).and_raise(client_error)

      expect(subject).to eq(false)
    end

    it 'raises other errors' do
      allow(client).to receive(:update!).with(entity_type, primary_key, attributes).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end
  end

  describe '.update!' do
    let(:verb) { :patch }
    let(:attributes) { { 'typeid' => 'some_id' } }
    let(:options) { attributes }
    let(:is_new) { false }
    let(:primary_key) { 'typeid' }

    subject { client.update!(entity_type, primary_key, attributes) }

    before do
      stub_request(verb, "#{connection_uri}/#{entity_type}(some_id)").to_return(body: body.to_json, headers: headers)
      allow(client).to receive(:service).and_return(service)
      allow(service).to receive(:[]).with(entity_type).and_return(entity_set)
      allow(entity_set).to receive(:new_entity).with(attributes).and_return(entity)
      allow(client).to receive(:to_url_chunk).with(entity).and_return(path)
      allow(entity).to receive(:is_new?).and_return(is_new)
    end

    it 'posts entity_set info and returns true' do
      expect(subject).to eq(true)
    end

    it 'raises errors that occur' do
      allow(client).to receive(:api_patch).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end

    context 'new entity (ie. has no id)' do
      let(:is_new) { true }
      let(:attributes) { {} }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'with @odata.bind properties' do
      let(:attributes) do
        {
          'ownerid@odata.bind': '/systemusers(12345)'
        }
      end
      it 'calls .update! with unmodified attributes' do
        expect(client).to receive(:update!).with(entity_type, primary_key, attributes).and_return(true)
        expect(subject).to be(true)
      end
    end

    context 'with additional headers' do
      let(:additional_header) { { 'header' => '1' } }

      before do
        stub_request(verb, uri).to_return(body: body.to_json, headers: headers.merge!(additional_header))
      end

      subject { client.update!(entity_type, primary_key, attributes, additional_header) }

      it 'should update' do
        expect(subject).to be(true)
      end

      it 'sets headers on the built request object' do
        expect_any_instance_of(Faraday::Builder).to receive(:build_response)
          .with(anything, have_attributes(headers: hash_including(additional_header)))

        subject
      end
    end
  end

  describe '.destroy' do
    subject { client.destroy(entity_type, id) }

    it 'calls .create! and returns true' do
      allow(client).to receive(:destroy!).with(entity_type, id).and_return(true)

      expect(subject).to be(true)
    end

    it 'returns false for expected exceptions' do
      allow(client).to receive(:destroy!).with(entity_type, id).and_raise(client_error)

      expect(subject).to eq(false)
    end

    it 'raises other errors' do
      allow(client).to receive(:destroy!).with(entity_type, id).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end
  end

  describe '.destroy!' do
    let(:verb) { :delete }

    subject { client.destroy!(entity_type, id) }

    it 'deletes entity_set and returns true' do
      allow(client).to receive(:service).and_return(service)
      allow(service).to receive(:[]).with(entity_type).and_return(entity_set)
      allow(entity_set).to receive(:query).and_return(query)
      allow(query).to receive(:find).with(id).and_return(path)

      expect(subject).to eq(true)
    end

    it 'raises exceptions' do
      allow(client).to receive(:service).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end
  end

  describe '.find' do
    subject { client.find(entity_type, id) }

    it 'returns found entity_set' do
      allow(client).to receive(:service).and_return(service)
      allow(service).to receive(:[]).with(entity_type).and_return(entity_set)
      allow(entity_set).to receive(:query).and_return(query)
      allow(query).to receive(:find).with(id, entity_type).and_return(path)
      allow(client).to receive(:build_entity).with(entity_type, body).and_return(entity)

      expect(subject).to eq(entity)
    end

    it 'raises any error that occurs' do
      allow(client).to receive(:service).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end
  end

  describe '.select' do
    let(:fields) { ['field'] }

    subject { client.select(entity_type, id, fields) }

    it 'returns selected entity and fields' do
      allow(client).to receive(:service).and_return(service)
      allow(service).to receive(:[]).with(entity_type).and_return(entity_set)
      allow(entity_set).to receive(:query).and_return(query)
      allow(query).to receive(:find).and_return(path)
      allow(client).to receive(:build_entity).with(entity_type, body).and_return(entity)

      expect(query).to receive(:select).exactly(fields.count).times
      expect(subject).to eq(entity)
    end

    it 'raises any error that occurs' do
      allow(client).to receive(:service).and_raise(StandardError)

      expect { subject }.to raise_error(StandardError)
    end
  end

  describe '.count' do
    let(:count) { 99 }
    let(:body) { { '@odata.count' => count } }

    subject { client.count(query) }

    context 'provided a Frodo::Query' do
      it 'uses query object to build count query and returns count' do
        allow(query).to receive(:is_a?).with(Frodo::Query.class).and_return(true)
        allow(query).to receive(:include_count)
        allow(query).to receive(:to_s).and_return(path)

        expect(subject).to eq(count.to_i)
      end

      it 'raises any error that occurs' do
        allow(query).to receive(:is_a?).with(Frodo::Query.class).and_raise(StandardError)

        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'provided a string that is entity_type' do
      let(:query) { entity_type }
      let(:frodo_query) { double(Frodo::Query) }
      let(:body) { count.to_s }

      it 'makes count query and retuns count' do
        allow(client).to receive(:service).and_return(service)
        allow(service).to receive(:[]).with(entity_type).and_return(entity_set)
        allow(entity_set).to receive(:query).and_return(frodo_query)
        allow(frodo_query).to receive(:count).and_return(path)

        expect(subject).to eq(count)
      end

      it 'raises any error that occurs' do
        allow(client).to receive(:service).and_raise(StandardError)

        expect { subject }.to raise_error(StandardError)
      end
    end
  end

  # private methods

  describe '.api_path' do
    subject { client.send(:api_path, path) }

    context 'base_path is defined' do
      let(:options) { { base_path: path } }

      it 'returns base_path + path' do
        allow(client).to receive(:options).and_return(options)

        expect(subject).to eq("#{path}/#{path}")
      end
    end

    it { should eq "/#{path}" }
  end

  describe '.build_entity' do
    let(:data) { 'data!!!!!' }

    subject { client.send(:build_entity, entity_type, data) }

    before do
      allow(client).to receive(:service).and_return(service)
      allow(service).to receive(:with_metadata?).and_return(true)
      allow(service).to receive(:[]).with(entity_type).and_return(entity_set)
      allow(entity_set).to receive(:entity_options).and_return(options)
    end
    context 'without metadata' do
      before { allow(service).to receive(:with_metadata?).and_return(false) }

      it 'parses single entity' do
        allow(client).to receive(:single_entity?).with(data).and_return(true)
        expect(subject).to eq(data)
      end

      context 'multiple entities' do
        let(:data) { { 'odata' => 'test', 'value' => 'data!!!' } }
        it 'parses multiple entities' do
          allow(client).to receive(:single_entity?).with(data).and_return(false)

          expect(subject).to eq(data['value'])
        end
      end
    end
    context 'with metadata' do
      before { allow(service).to receive(:with_metadata?).and_return(true) }
      it 'parses single entity' do
        expect(client).to receive(:single_entity?).with(data).and_return(true)
        expect(client).to receive(:parse_entity).with(data, options)
        subject
      end

      context 'multiple entities' do
        let(:data) { { 'odata' => 'test', 'value' => 'data!!!' } }
        it 'parses multiple entities' do
          expect(client).to receive(:single_entity?).with(data).and_return(false)
          expect(client).to receive(:parse_entities).with(data, options)
          subject
        end
      end
    end
  end

  describe '.single_entity?' do
    let(:body) { { '@odata.context' => '$entity' } }

    subject { client.send(:single_entity?, body) }

    it "returns true when context contains string '$entity'" do
      expect(subject).to be_truthy
    end

    context "body context does not contain '$entity'" do
      let(:body) { { '@odata.context' => 'other' } }

      it { should be(nil) }
    end
  end

  describe '.parse_entity' do
    let(:entity_data) { {} }

    subject { client.send(:parse_entity, entity_data, options) }

    it 'builds Frodo::Entity' do
      expect(Frodo::Entity).to receive(:from_json).with(entity_data, options)
      subject
    end
  end

  describe '.parse_entities' do
    let(:entity_data) { 'data!!!' }
    let(:data_value) { [entity_data, entity_data] }
    let(:data) { { 'value' => data_value } }

    subject { client.send(:parse_entities, data, options) }

    it 'builds Frodo::Entity from body value' do
      expect(Frodo::Entity).to receive(:from_json).with(entity_data, options).exactly(data_value.count).times
      subject
    end
  end

  describe '.to_url_chunk' do
    let(:primary_key) { 'I am the key!' }
    let(:property) { double }
    let(:set) { 'Who am I?' }

    subject { client.send(:to_url_chunk, entity) }

    before do
      allow(entity).to receive(:primary_key).and_return(primary_key)
      allow(entity).to receive(:get_property).with(primary_key).and_return(property)
      allow(property).to receive(:url_value).and_return(primary_key)
      allow(entity).to receive(:entity_set).and_return(entity_set)
      allow(entity_set).to receive(:name).and_return(set)
    end

    context 'entities with ids' do
      it 'returns key composed with private key' do
        allow(entity).to receive(:is_new?).and_return(false)

        expect(subject).to eq("#{set}(#{primary_key})")
      end
    end

    context 'new entities' do
      it 'returns key composed without private key' do
        allow(entity).to receive(:is_new?).and_return(true)

        expect(subject).to eq(set)
      end
    end
  end
end
