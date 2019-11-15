# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe Frodo::Middleware::Authentication::ClientCredentials do
  include WebMock::API

  describe 'authentication middleware' do
    let(:options) do
      { client_id: 'client_id',
        client_secret: 'client_secret',
        tenant_id: 'tenant_id',
        adapter: :net_http,
        host: 'login.window.net'
      }
    end

      let(:success_request) do
        stub_request(:post, "https://login.window.net/tenant_id/oauth2/token").with(
          body: "grant_type=client_credentials&" \
                   "client_id=client_id&client_secret=client_secret"
        ).to_return(status: 200, body: fixture("client_credentials_auth_success_response"))
      end

      let(:fail_request) do
        stub_request(:post, "https://login.window.net/tenant_id/oauth2/token").with(
          body: "grant_type=client_credentials&" \
                   "client_id=client_id&client_secret=client_secret"
        ).to_return(status: 400, body: fixture("client_credentials_refresh_error_response"))
      end

    describe '.authenticate!' do
      context 'when successful' do
        let!(:request) { success_request }

        describe '@options' do
          subject { options }

          before do
            middleware.authenticate!
          end

          it { expect(subject[:host]).to eq 'login.window.net' }

          it { expect(subject[:oauth_token]).to eq "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsI" }

          it { expect(subject[:refresh_token]).to be_nil }
        end

        context 'when an authentication_callback is specified' do
          before(:each) do
            options.merge!(authentication_callback: auth_callback)
          end

          it 'calls the authentication callback with the response body' do
            expect(auth_callback).to receive(:call)
            middleware.authenticate!
          end
        end
      end

      context 'when unsuccessful' do
        let!(:request) { fail_request }

        it 'raises an exception' do
          expect {
            middleware.authenticate!
          }.to raise_error Frodo::AuthenticationError
        end

        context 'when an authentication_callback is specified' do
          before(:each) do
            options.merge!(authentication_callback: auth_callback)
          end

          it 'does not call the authentication callback' do
            expect(auth_callback).to_not receive(:call)
            expect do
              middleware.authenticate!
            end.to raise_error(Frodo::AuthenticationError)
          end
        end
      end
    end
  end
end
