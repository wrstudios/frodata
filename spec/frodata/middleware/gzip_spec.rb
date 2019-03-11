# frozen_string_literal: true

require 'spec_helper'

describe FrOData::Middleware::Gzip do
  let(:options) { { oauth_token: 'token' } }

  # Return a gzipped string.
  def gzip(str)
    StringIO.new.tap do |io|
      gz = Zlib::GzipWriter.new(io)
      gz.write(str)
      gz.close
    end.string
  end

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    before do
      expect(app).to receive(:on_complete) { middleware.on_complete(env) }
      expect(app).to receive(:call) do
        env[:body] = gzip fixture('leads')
        env[:response_headers]['Content-Encoding'] = 'gzip'
        app
      end
    end

    it 'decompresses the body' do
      should change { env[:body] }.to(fixture('leads'))
    end

    context 'when :compress is false' do
      it { should_not(change { env[:request_headers]['Accept-Encoding'] }) }
    end

    context 'when :compress is true' do
      before do
        options[:compress] = true
      end

      it { should(change { env[:request_headers]['Accept-Encoding'] }.to('gzip')) }
    end
  end

  describe '.decompress' do
    let(:body) { gzip fixture('leads') }

    subject { middleware.decompress(body) }
    it { should eq fixture('leads') }
  end

  describe '.gzipped?' do
    subject { middleware.gzipped?(env) }

    context 'when gzipped' do
      before do
        env[:response_headers]['Content-Encoding'] = 'gzip'
      end

      it { should be_truthy }
    end

    context 'when not gzipped' do
      it { should be_falsey }
    end
  end
end
