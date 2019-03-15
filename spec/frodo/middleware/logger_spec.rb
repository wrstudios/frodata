# frozen_string_literal: true

require 'spec_helper'

describe Frodo::Middleware::Logger do
  let(:logger)     { double('logger') }
  let(:middleware) { described_class.new app, logger, options }

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    before do
      expect(app).to receive(:call).once.and_return(app)
      expect(app).to receive(:on_complete).once { middleware.on_complete(env) }
      expect(logger).to receive(:debug).with('request')
      expect(logger).to receive(:debug).with('response')
    end

    it { should_not raise_error }
  end
end
