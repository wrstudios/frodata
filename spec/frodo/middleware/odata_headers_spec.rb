# frozen_string_literal: true

require 'spec_helper'

describe Frodo::Middleware::OdataHeaders do
  describe '.call' do

    before do
      subject.call(env)
    end

    it { expect(env[:request_headers]['OData-Version']).to eq '4.0' }
    it { expect(env[:request_headers]['Content-type']).to eq 'application/json' }
  end
end
