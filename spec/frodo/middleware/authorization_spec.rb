# frozen_string_literal: true

require 'spec_helper'

describe Frodo::Middleware::Authorization do
  let(:options) { { oauth_token: 'token' } }

  describe '.call' do
    subject { middleware }

    before do
      subject.call(env)
    end

    it { expect(env[:request_headers]['Authorization']).to eq 'Bearer token' }
  end
end
