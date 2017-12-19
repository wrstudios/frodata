require 'spec_helper'

shared_examples 'a valid criterium' do |operator, value, to_s|
  it { expect(criteria).to eq(subject) }
  it { expect(criteria.operator).to eq(operator) }
  it { expect(criteria.value).to eq(value) }
  it { expect(criteria.to_s).to eq(to_s) }
end

describe OData::Query::Criteria do
  let(:string_property) { OData::Properties::String.new(:Name, nil) }
  let(:integer_property) { OData::Properties::Integer.new(:Age, nil) }
  let(:subject) { OData::Query::Criteria.new(property: string_property) }

  it { expect(subject).to respond_to(:property) }
  it { expect(subject.property).to eq(string_property)}

  it { expect(subject).to respond_to(:operator) }
  it { expect(subject).to respond_to(:value) }
  it { expect(subject).to respond_to(:to_s) }

  describe 'comparison operators' do
    describe '#eq' do
      let(:criteria) { subject.eq('Bread') }

      it { expect(subject).to respond_to(:eq) }
      it_behaves_like 'a valid criterium', :eq, 'Bread', "Name eq 'Bread'"
    end

    describe '#ne' do
      let(:criteria) { subject.ne('Bread') }

      it { expect(subject).to respond_to(:ne) }
      it_behaves_like 'a valid criterium', :ne, 'Bread', "Name ne 'Bread'"
    end

    describe '#gt' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.gt(5) }

      it { expect(subject).to respond_to(:gt) }
      it_behaves_like 'a valid criterium', :gt, 5, "Age gt 5"
    end

    describe '#ge' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.ge(5) }

      it { expect(subject).to respond_to(:ge) }
      it_behaves_like 'a valid criterium', :ge, 5, 'Age ge 5'
    end

    describe '#lt' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.lt(5) }

      it { expect(subject).to respond_to(:lt) }
      it_behaves_like 'a valid criterium', :lt, 5, 'Age lt 5'
    end

    describe '#le' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.le(5) }

      it { expect(subject).to respond_to(:le) }
      it_behaves_like 'a valid criterium', :le, 5, 'Age le 5'
    end
  end
end
