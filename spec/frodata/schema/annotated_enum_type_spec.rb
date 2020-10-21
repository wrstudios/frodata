require 'spec_helper'

describe FrOData::Schema::EnumType, vcr: {cassette_name: 'schema/enum_type_specs'} do
  before(:example) do
    FrOData::Service.new('http://services.odata.org/V4/OData/OData.svc', name: 'ODataDemo', metadata_file: metadata_file)
  end

  let(:metadata_file) { 'spec/fixtures/files/metadata.xml' }
  let(:service) { FrOData::ServiceRegistry['ODataDemo'] }

  let(:enum_type) { service.enum_types['ODataDemo.Vertical'] }
  let(:subject) { enum_type.property_class.new('Vertical', nil) }

  describe 'is properly parsed from service metadata' do
    it { expect(enum_type.name).to eq('Vertical') }
    it { expect(enum_type.namespace).to eq('ODataDemo') }
    it { expect(enum_type.type).to eq('ODataDemo.Vertical') }
    it { expect(enum_type.is_flags?).to eq(false) }
    it { expect(enum_type.underlying_type).to eq('Edm.Int64') }
    it { expect(enum_type.members.values).to eq(%w{OutdoorsAndNature HomeAndOffice}) }
    it {
      expect(enum_type.annotated_members).to eq({
        1 => { name: 'OutdoorsAndNature', annotation: 'Outdoor and Nature Products' },
        2 => { name: 'HomeAndOffice', annotation: 'Home and Office Products' }
      })
    }
  end

  # Check property instance inheritance hierarchy
  it { expect(subject).to be_a(FrOData::Property) }
  it { expect(subject).to be_a(FrOData::Properties::Enum) }

  it { expect(subject).to respond_to(:name) }
  it { expect(subject).to respond_to(:type) }
  it { expect(subject).to respond_to(:members) }

end
