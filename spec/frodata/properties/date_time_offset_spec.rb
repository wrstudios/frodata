require 'spec_helper'

describe FrOData::Properties::DateTimeOffset do
  let(:subject) { FrOData::Properties::DateTimeOffset.new('DateTime', '2000-01-01T16:00:00-09:00') }
  let(:new_datetime) { DateTime.strptime('2004-05-01T14:32:00+02:00', '%Y-%m-%dT%H:%M:%S%:z') }

  it { expect(subject.type).to eq('Edm.DateTimeOffset') }
  it { expect(subject.value).to eq(DateTime.strptime('2000-01-01T16:00:00-09:00', '%Y-%m-%dT%H:%M:%S%:z')) }

  it { expect(subject.url_value).to eq("2000-01-01T16:00:00-09:00")}

  it { expect {subject.value = 'bad'}.to raise_error(ArgumentError) }

  it { expect(lambda {
    subject.value = new_datetime
    subject.value
  }.call).to eq(new_datetime) }

  it { expect(lambda {
    subject.value = nil
  }).not_to raise_error }

  context 'with allows_nil option set to false' do
    let(:subject) { FrOData::Properties::DateTimeOffset.new('DateTime', '2000-01-01T16:00:00Z-09:00', allows_nil: false) }

    it { expect(lambda {
      subject.value = nil
    }).to raise_error(ArgumentError) }
  end
end
