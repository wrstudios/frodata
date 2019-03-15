# frozen_string_literal: true

require 'spec_helper'

describe Frodo::Concerns::Base do

  let(:klass) do
    context = self
    Class.new {
      include Frodo::Concerns::Connection
      include context.described_class
    }
  end

  let(:client) { klass.new }

  subject { client }

  describe '#new' do
    context 'without options passed in' do
      it 'does not raise an exception' do
        expect {
          klass.new
        }.to_not raise_error
      end
    end

    context 'with a non-hash value' do
      it 'raises an ArgumentError exception' do
        expect {
          klass.new 'foo'
        }.to raise_error ArgumentError, 'Please specify a hash of options'
      end
    end

    it 'yields the builder to the block' do
      expect_any_instance_of(klass).to receive(:builder)
      expect { |b| klass.new(&b) }.to yield_control
    end
  end

  describe '.options' do
    subject { lambda { client.options } }
    it { should_not raise_error }
  end

  describe '.instance_url' do
    subject { client.instance_url }

    context 'when options[:instance_url] is unset' do
      it 'triggers an authentication' do
        def client.authenticate!
        end
        allow(client).to receive(:authenticate!)
        expect(client).to receive :authenticate!
        subject
      end
    end

    context 'when options[:instance_url] is set' do
      before do
        expect(client).to receive(:options).and_return({ instance_url: 'foo' }).twice
      end

      it { should eq 'foo' }
    end
  end
end
