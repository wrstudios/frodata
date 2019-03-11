# frozen_string_literal: true

require 'spec_helper'

describe FrOData::Middleware::InstanceURL do
  describe '.call' do
    subject { lambda { middleware.call(nil) } }
    let(:connection) { double("connection") }

    context 'when the instance url is not set' do
      before do
        allow(client).to receive_message_chain :connection, url_prefix: URI.parse('http:/')
      end

      it { should raise_error FrOData::UnauthorizedError }
    end

    context 'when the instance url is set' do
      before do
        allow(client).to receive_message_chain :connection, url_prefix: URI.parse('http://foobar.com/')
        expect(app).to receive(:call).once
      end

      it { should_not raise_error }
    end
  end
end
