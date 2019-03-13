# frozen_string_literal: true

require 'spec_helper'

describe FrOData::Middleware::Authentication do
  let(:options) do
    { host: 'login.windows.net',
      proxy_uri: 'https://not-a-real-site.com',
      authentication_retries: retries,
      adapter: :net_http,
      ssl: { version: :TLSv1_2 } }
  end

  describe '.authenticate!' do
    subject { lambda { middleware.authenticate! } }
    it      { should raise_error NotImplementedError }
  end

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    context 'when successfull' do
      before do
        expect(app).to receive(:call).once
      end

      it { should_not raise_error }
    end

    context 'when an exception is thrown' do
      before do
        expect(middleware).to receive(:authenticate!)
        expect(app).to receive(:call).once.
          and_raise(FrOData::UnauthorizedError.new('something bad'))
      end

      it { should raise_error FrOData::UnauthorizedError }
    end
  end

  describe '.connection' do
    subject(:connection) { middleware.connection }

    it { expect(subject.url_prefix).to eq(URI.parse('https://login.windows.net')) }

    it "should have a proxy URI" do
      expect(connection.proxy[:uri]).to eq(URI.parse('https://not-a-real-site.com'))
    end

    describe '.builder' do
      subject(:builder) { connection.builder }

      context 'with logging disabled' do
        before do
          expect(FrOData).to receive(:log?).and_return(false)
        end

        it { expect(subject.handlers).to include FaradayMiddleware::ParseJson, Faraday::Adapter::NetHttp }
        it { expect(subject.handlers).not_to include FrOData::Middleware::Logger }
      end

      context 'with logging enabled' do
        before do
          expect(FrOData).to receive(:log?).and_return(true)
        end

        it { expect(subject.handlers).to include FaradayMiddleware::ParseJson, Faraday::Adapter::NetHttp, FrOData::Middleware::Logger }
      end

      context 'with specified adapter' do
        before do
          options[:adapter] = :typhoeus
        end

        it { expect(subject.handlers).to include FaradayMiddleware::ParseJson, Faraday::Adapter::Typhoeus }
      end
    end

    it "should have SSL config set" do
      expect(connection.ssl[:version]).to eq(:TLSv1_2)
    end
  end
end
