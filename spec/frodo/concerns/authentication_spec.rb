# frozen_string_literal: true

require 'spec_helper'

describe Frodo::Concerns::Authentication do
  let(:klass) do
    context = self
    Class.new {
      include Frodo::Concerns::Base
      include context.described_class
    }
  end

  let(:client) { klass.new }
  subject { client }

  describe '.authenticate!' do
    subject(:authenticate!) { client.authenticate! }

    context 'when there is no authentication middleware' do
      before do
        expect(client).to receive(:authentication_middleware).and_return(nil)
      end

      it "raises an error" do
        expect { authenticate! }.to raise_error Frodo::AuthenticationError,
                                                'No authentication middleware present'
      end
    end

    context 'when there is authentication middleware' do
      let(:authentication_middleware) { double('Authentication Middleware') }
      subject(:result) { client.authenticate! }

      it 'authenticates using the middleware' do
        expect(client).to receive(:authentication_middleware).and_return(authentication_middleware).twice
        expect(client).to receive(:options).twice

        expect(authentication_middleware).to receive(:new).with(nil, client, client.options).and_return(double(authenticate!: 'foo'))
        expect(result).to eq 'foo'
      end
    end
  end

  describe '.authentication_middleware' do
    subject { client.authentication_middleware }

    context 'when oauth options are provided' do
      before do
        expect(client).to receive(:oauth_refresh?).and_return(true)
      end

    it { should eq Frodo::Middleware::Authentication::Token }
    end
  end

  describe '.oauth_refresh?' do
    subject       { client.oauth_refresh? }
    let(:options) { {} }

    before do
      expect(client).to receive(:options).and_return(options).at_least(1).times
    end

    context 'when oauth options are provided' do
      let(:options) do
        { refresh_token: 'token',
          client_id: 'client',
          client_secret: 'secret' }
      end

      it { should be_truthy}
    end

    context 'when oauth options are not provided' do
      it { should_not be_truthy }
    end
  end
end
