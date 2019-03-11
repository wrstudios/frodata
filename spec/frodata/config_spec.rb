# frozen_string_literal: true

require 'spec_helper'

describe FrOData do
  before do
    ENV['DYNAMICS_V1_CLIENT_ID']      = nil
    ENV['DYNAMICS_V1_CLIENT_SECRET']  = nil
  end

  after do
    FrOData.instance_variable_set :@configuration, nil
  end

  describe '#configuration' do
    subject { FrOData.configuration }

    it { should be_a FrOData::Configuration }

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
      FrOData.configure do |config|
          config.send("#{attr}=", 'foobar')
        end
        expect(FrOData.configuration.send(attr)).to eq 'foobar'
      end
    end
  end

  describe '#log?' do
    subject { FrOData.log? }

    context 'by default' do
      it { should be_falsey }
    end
  end

  describe '#log' do
    context 'with logging disabled' do
      before do
        allow(FrOData).to receive(:log?).and_return(false)
      end

      it 'doesnt log anytning' do
        expect(FrOData.configuration.logger).not_to receive(:debug)
        FrOData.log 'foobar'
      end
    end

    context 'with logging enabled' do
      before do
        allow(FrOData).to receive(:log?).and_return(true)
      end

      it 'logs something' do
        expect(FrOData.configuration.logger).to receive(:debug).with('foobar')
        FrOData.log 'foobar'
      end

      context "with a custom logger" do
        let(:fake_logger) { double(debug: true) }

        before do
          FrOData.configure do |config|
            config.logger = fake_logger
          end
        end

        it "logs using the provided logger" do
          expect(fake_logger).to receive(:debug).with('foobar')
          FrOData.log('foobar')
        end
      end

      context "with a custom log_level" do
        before do
          FrOData.configure do |config|
            config.log_level = :info
          end
        end

        it 'logs with the provided log_level' do
          expect(FrOData.configuration.logger).to receive(:info).with('foobar')
          FrOData.log 'foobar'
        end
      end
    end
  end

  describe '.new' do
    it 'calls its block' do
      checker = double(:block_checker)
      expect(checker).to receive(:check!).once
      FrOData.new do |builder|
        checker.check!
      end
    end
  end
end
