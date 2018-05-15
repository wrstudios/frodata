require 'spec_helper'

describe FrOData::Property do
  let(:service) do
    FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', metadata_file: metadata_file)
  end
  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:subject) { FrOData::Property.new('PropertyName', '1') }
  let(:good_comparison) { FrOData::Property.new('GoodComparison', '1') }
  let(:bad_comparison) { FrOData::Property.new('BadComparison', '2') }

  describe '#name' do
    it { expect(subject).to respond_to(:name) }
    it { expect(subject.name).to eq('PropertyName') }
  end

  describe '#value' do
    it { expect(subject).to respond_to(:value) }
    it { expect(subject.value).to eq('1') }
  end

  describe '#xml_value' do
    it { expect(subject).to respond_to(:xml_value) }
    it { expect(subject.xml_value).to eq('1') }
  end

  describe '#url_value' do
    it { expect(subject).to respond_to(:url_value) }
    it { expect(subject.url_value).to eq('1') }
  end

  describe '#type' do
    it { expect(subject).to respond_to(:type) }
    it { expect(lambda {subject.type}).to raise_error(NotImplementedError) }
  end

  describe '#allows_nil?' do
    it { expect(subject).to respond_to(:allows_nil?) }
    it { expect(subject.allows_nil?).to eq(true) }
  end

  describe '#strict?' do
    it { expect(subject).to respond_to(:strict?) }

    it 'defaults to true' do
      expect(subject.strict?).to eq(true)
    end

    it 'can be switched off via constructor option' do
      subject = FrOData::Property.new('PropertyName', '1', strict: false)
      expect(subject.strict?).to eq(false)
    end

    it 'can be switched off via service level option' do
      service.options[:strict] = false
      subject = FrOData::Property.new('PropertyName', '1', service: service)
      expect(subject.strict?).to eq(false)
    end
  end

  describe '#concurrency_mode' do
    it { expect(subject).to respond_to(:concurrency_mode) }
    it { expect(subject.concurrency_mode).to eq(:none) }
  end

  describe '#==' do
    it { expect(subject).to respond_to(:==) }
    it { expect(subject == good_comparison).to eq(true) }
    it { expect(subject == bad_comparison).to eq(false) }
  end
end
