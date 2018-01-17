require 'spec_helper'

describe OData4::PropertyRegistry do
  let(:subject) { OData4::PropertyRegistry }

  it { expect(subject).to respond_to(:add) }
  it { expect(subject).to respond_to(:[]) }

  describe '#add' do
    before(:each) do
      subject.add('Edm.Guid', OData4::Properties::Guid)
    end

    it { expect(subject['Edm.Guid']).to eq(OData4::Properties::Guid) }
  end
end