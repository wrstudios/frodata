# frozen_string_literal: true

require 'spec_helper'

describe Frodo do
  before do
    ENV['DYNAMICS_V1_CLIENT_ID']      = nil
    ENV['DYNAMICS_V1_CLIENT_SECRET']  = nil
  end

  after do
    Frodo.instance_variable_set :@configuration, nil
  end

  describe '#configuration' do
    subject { Frodo.configuration }

    it { should be_a Frodo::Configuration }

    context 'by default' do
      it { expect(subject.host).to  eq 'login.microsoftonline.com' }
      it { expect(subject.authentication_retries).to eq 3 }
      it { expect(subject.adapter).to eq Faraday.default_adapter }
      it { expect(subject.ssl).to eq({}) }
      %i[client_id client_secret
         oauth_token refresh_token instance_url compress timeout
         proxy_uri authentication_callback request_headers].each do |attr|
        it { expect(subject.send(attr)).to be_nil }
      end
    end

    context 'when environment variables are defined' do
      before do
        {
          'FRODATA_PROXY_URI'      => 'proxy',
        }.
          each { |var, value| allow(ENV).to receive(:[]).with(var).and_return(value) }
      end

      it { expect(subject.proxy_uri).to eq 'proxy' }
    end
  end

  describe '#configure' do
    %i[client_id client_secret compress
       timeout oauth_token refresh_token instance_url host
       authentication_retries proxy_uri authentication_callback ssl
       request_headers log_level logger].each do |attr|
      it "allows #{attr} to be set" do
      Frodo.configure do |config|
          config.send("#{attr}=", 'foobar')
        end
        expect(Frodo.configuration.send(attr)).to eq 'foobar'
      end
    end
  end

  describe '#log?' do
    subject { Frodo.log? }

    context 'by default' do
      it { should be_falsey }
    end
  end

  describe '#log' do
    context 'with logging disabled' do
      before do
        allow(Frodo).to receive(:log?).and_return(false)
      end

      it 'doesnt log anytning' do
        expect(Frodo.configuration.logger).not_to receive(:debug)
        Frodo.log 'foobar'
      end
    end

    context 'with logging enabled' do
      before do
        allow(Frodo).to receive(:log?).and_return(true)
      end

      it 'logs something' do
        expect(Frodo.configuration.logger).to receive(:debug).with('foobar')
        Frodo.log 'foobar'
      end

      context "with a custom logger" do
        let(:fake_logger) { double(debug: true) }

        before do
          Frodo.configure do |config|
            config.logger = fake_logger
          end
        end

        it "logs using the provided logger" do
          expect(fake_logger).to receive(:debug).with('foobar')
          Frodo.log('foobar')
        end
      end

      context "with a custom log_level" do
        before do
          Frodo.configure do |config|
            config.log_level = :info
          end
        end

        it 'logs with the provided log_level' do
          expect(Frodo.configuration.logger).to receive(:info).with('foobar')
          Frodo.log 'foobar'
        end
      end
    end
  end

  describe '.new' do
    it 'calls its block' do
      checker = double(:block_checker)
      expect(checker).to receive(:check!).once
      Frodo.new do |builder|
        checker.check!
      end
    end
  end
end
