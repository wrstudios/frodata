require 'spec_helper'

describe Frodo::PropertyRegistry do
  let(:subject) { Frodo::PropertyRegistry }

  it { expect(subject).to respond_to(:add) }
  it { expect(subject).to respond_to(:[]) }

  describe '#add' do
    before(:each) do
      subject.add('Edm.Guid', Frodo::Properties::Guid)
    end

    it { expect(subject['Edm.Guid']).to eq(Frodo::Properties::Guid) }
  end
end