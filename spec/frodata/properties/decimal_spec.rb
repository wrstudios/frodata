require 'spec_helper'

describe FrOData::Properties::Decimal do
  let(:subject) { FrOData::Properties::Decimal.new('Decimal', '678.90325') }

  it { expect(subject.type).to eq('Edm.Decimal') }
  it { expect(subject.value).to eq(BigDecimal('678.90325')) }

  it { expect(subject.url_value).to eq('678.90325') }

  it { expect { subject.value = BigDecimal((7.9 * (10**28)), 2) + 1 }.to raise_error(ArgumentError) }
  it { expect { subject.value = BigDecimal((-7.9 * (10**28)), 2) - 1 }.to raise_error(ArgumentError) }
  it { expect { subject.value = BigDecimal((3.4 * (10**-28)), 2) * 3.14151 + 5 }.to raise_error(ArgumentError) }

  describe '#value=' do
    it 'allows BigDecimal to be set' do
      subject.value = BigDecimal('19.89043256')
      expect(subject.value).to eq(BigDecimal('19.89043256'))
    end

    it 'allows string value to be set' do
      subject.value = '19.89043256'
      expect(subject.value).to eq(BigDecimal('19.89043256'))
    end

    it 'ignores invalid characters' do
      skip "Broken past Ruby 2.4"
      subject.value = '123.4-foobar-5'
      expect(subject.value).to eq(BigDecimal('123.4'))
    end

    it 'inteprets anything that is not a number as 0' do
      skip "Broken past Ruby 2.4"
      subject.value = 'foobar'
      expect(subject.value).to eq(BigDecimal(0))
    end

    it 'does not allow values outside a certain range' do
      expect { subject.value = 'Infinity' }.to raise_error(ArgumentError)
    end

    describe 'lenient validation' do
      let(:subject) do
        FrOData::Properties::Decimal.new('Decimal', '678.90325', strict: false)
      end

      it 'ignores invalid values' do
        subject.value = 'Infinity'
        expect(subject.value).to eq(BigDecimal('Infinity'))
      end
    end
  end
end
