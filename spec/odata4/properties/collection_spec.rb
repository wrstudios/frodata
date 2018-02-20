require 'spec_helper'

describe OData4::Properties::Collection do
  let(:subject) { OData4::Properties::Collection.new('Names', names) }
  let(:names) { %w[Dan Greg Jon] }
  let(:new_names) { %w[Andrew Doug Paul] }

  it { expect(subject.type).to eq('Collection(Edm.String)') }
  it { expect(subject.value).to eq(['Dan', 'Greg', 'Jon']) }
  it { expect(subject.url_value).to eq("['Dan','Greg','Jon']") }

  describe '#value=' do
    it 'allows an array of string values to be set' do
      subject.value = new_names
      expect(subject.value).to eq(new_names)
    end
  end

  # TODO: Make collection type work properly with data types other than string
  xcontext 'with value type other than Edm.String' do
    let(:subject) { OData4::Properties::Collection.new('Bits', [1, 0, 1], value_type: 'Edm.Binary') }

    it { expect(subject.type).to eq('Collection(Edm.Int32)') }
    it { expect(subject.value).to eq([1, 0, 1]) }
    it { expect(subject.url_value).to eq('[1,0,1]') }

    it 'does not allow other property types to be set' do
      expect {
        subject.value = names
      }.to raise_error(ArgumentError)
    end

    xdescribe 'lenient validation' do
      let(:subject) do
        OData4::Properties::Collection.new('Names', names, value_type: 'Edm.String', strict: false)
      end

      it 'ignores invalid values' do
        subject.value = [1, 2, 3]
        expect(subject.value).to eq([])
      end
    end
  end
end
