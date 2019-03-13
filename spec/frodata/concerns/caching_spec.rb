# frozen_string_literal: true

require 'spec_helper'

describe FrOData::Concerns::Caching do
  describe '.without_caching' do
    let(:options) { double('Options') }
    let(:klass) do
      context = self
      Class.new {
        include FrOData::Concerns::Base
        include context.described_class
      }
    end
    let(:client) { klass.new }
    subject { client }

    before do
      expect(client).to receive(:options).and_return(options).twice
    end

    it 'runs the block with caching disabled' do
      expect(options).to receive(:[]=).with(:use_cache, false)
      expect(options).to receive(:delete).with(:use_cache)
      expect { |b| client.without_caching(&b) }.to yield_control
    end

    context 'when an exception is raised' do
      it 'ensures the :use_cache is deleted' do
        expect(options).to receive(:[]=).with(:use_cache, false)
        expect(options).to receive(:delete).with(:use_cache)
        expect {
          client.without_caching do
            raise 'Foo'
          end
        }.to raise_error 'Foo'
      end
    end
  end
end
