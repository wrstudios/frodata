require 'spec_helper'

describe FrOData::Properties::TimeOfDay do
  let(:subject) { FrOData::Properties::TimeOfDay.new('TimeOfDay', '16:00:00.000') }
  let(:new_time) { Time.strptime('14:32:00.000', '%H:%M:%S.%L') }

  it { expect(subject.type).to eq('Edm.TimeOfDay') }
  it { expect(subject.value).to eq(Time.parse('16:00:00.000')) }

  it { expect(subject.url_value).to eq("16:00:00.000")}

  it { expect {subject.value = 'bad'}.to raise_error(ArgumentError) }

  it { expect(lambda {
    subject.value = '14:32:00.000'
    subject.value
  }.call).to eq(new_time) }

  it { expect(lambda {
    subject.value = new_time
    subject.value
  }.call).to eq(new_time) }
end
