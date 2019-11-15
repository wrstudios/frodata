# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe Frodo::Middleware::Authentication::Password do
  include WebMock::API

  describe 'authentication middleware' do
    let(:options) do
      { client_id: 'client_id',
        tenant_id: 'tenant_foo_id',
        username: 'username',
        password: 'password',
        adapter: :net_http,
        host: 'login.window.net',
        instance_url: "https://endpoint.example.com",
      }
    end

      let(:success_request) do
        stub_request(:post, "https://login.window.net/#{options[:tenant_id]}/oauth2/token").with(
          body: {
            "client_id"=>options[:client_id], "grant_type"=>"password", "password"=>options[:password],
            "resource"=>options[:instance_url], "username"=>options[:username]
          },
        ).to_return(status: 200, body: fixture("password_auth_success_response"))
      end

      let(:fail_request) do
        stub_request(:post, "https://login.window.net/#{options[:tenant_id]}/oauth2/token").with(
          body: {
            "client_id"=>options[:client_id], "grant_type"=>"password", "password"=>options[:password],
            "resource"=>options[:instance_url], "username"=>options[:username]
          },
        ).to_return(status: 400, body: fixture("password_auth_failure_response"))
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

          it { expect(subject[:oauth_token]).to eq "eyJ0eXAiOiJKV1QiLCJhbGciOi" }

          it { expect(subject[:refresh_token]).to eq 'AQABAAAAAACQN9QBRU3jT6bcBQLZ' }
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
