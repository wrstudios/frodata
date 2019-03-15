# frozen_string_literal: true

require 'spec_helper'

describe Frodo::Concerns::Connection do
  let(:options) { double('Options') }
  let(:klass) do
    context = self
    Class.new {
      include Frodo::Concerns::Base
      include Frodo::Concerns::Authentication
      include Frodo::Concerns::Caching
      include context.described_class
    }
  end

  let(:client) { klass.new }
  subject { client }

  describe '.middleware' do
    subject       { client.middleware }
    let(:builder) { double('Faraday::Builder') }

    before do
      expect(client).to receive_message_chain(:connection, builder: builder)
    end

    it { should eq builder }
  end

  describe "#connection_options" do
    let(:options) { { ssl: { verify: false } } }
    before { expect(client).to receive(:options).and_return(options).exactly(4).times }

    it "picks up passed-in SSL options" do
      expect(client.send(:connection_options)).to include(options)
    end
  end

  describe 'private #connection' do

    describe ":logger option" do
      let(:options) { { adapter: Faraday.default_adapter } }

      before(:each) do
        expect(client).to receive(:authentication_middleware)
        expect(client).to receive(:cache)
        expect(client).to receive(:options).and_return(options).at_least(1)
        expect(Frodo).to receive(:log?).and_return(true)
      end

      it "must always be used last before the Faraday Adapter" do
        expect(client.middleware.handlers.reverse.index(Frodo::Middleware::Logger)).to eq 1
      end
    end
  end

  describe '#adapter' do
    before do
      expect(client).to receive(:options).and_return({ adapter: :typhoeus })
    end

    it { expect(subject.options[:adapter]).to eq(:typhoeus) }
  end
end
