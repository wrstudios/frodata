require 'spec_helper'

describe OData::Properties::Date do
  let(:subject) { OData::Properties::Date.new('Date', '2000-01-01') }
  let(:new_date) { Date.strptime('2004-05-01', '%Y-%m-%d') }

  it { expect(subject.type).to eq('Edm.Date') }
  it { expect(subject.value).to eq(Date.parse('2000-01-01')) }

  it { expect(subject.url_value).to eq("2000-01-01")}

  it { expect {subject.value = 'bad'}.to raise_error(ArgumentError) }

  it { expect(lambda {
    subject.value = '2004-05-01'
    subject.value
  }.call).to eq(new_date) }

  it { expect(lambda {
    subject.value = new_date
    subject.value
  }.call).to eq(new_date) }
end
