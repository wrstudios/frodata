require 'spec_helper'

describe OData::NavigationProperty do
  let(:subject) do
    OData::NavigationProperty.new(
      name: 'Categories',
      type: 'Collection(ODataDemo.Category)',
      partner: 'Products',
    )
  end

  it { expect(subject).to respond_to(:name) }
  it { expect(subject.name).to eq('Categories') }

  it { expect(subject).to respond_to(:type) }
  it { expect(subject.type).to eq('Collection(ODataDemo.Category)') }

  it { expect(subject).to respond_to(:nullable) }
  
  it { expect(subject).to respond_to(:partner) }
  it { expect(subject.partner).to eq('Products') }
end
