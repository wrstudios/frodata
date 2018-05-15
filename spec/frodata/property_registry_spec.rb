require 'spec_helper'

describe FrOData::PropertyRegistry do
  let(:subject) { FrOData::PropertyRegistry }

  it { expect(subject).to respond_to(:add) }
  it { expect(subject).to respond_to(:[]) }

  describe '#add' do
    before(:each) do
      subject.add('Edm.Guid', FrOData::Properties::Guid)
    end

    it { expect(subject['Edm.Guid']).to eq(FrOData::Properties::Guid) }
  end
end