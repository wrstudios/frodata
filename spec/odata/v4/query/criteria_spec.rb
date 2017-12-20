require 'spec_helper'

shared_examples 'an operator criterium' do |operator, value, to_s|
  it { expect(criteria).to eq(subject) }
  it { expect(criteria.operator).to eq(operator) }
  it { expect(criteria.value).to eq(value) }
  it { expect(criteria.to_s).to eq(to_s) }
end

shared_examples 'a function criterium' do |function, argument, to_s|
  it { expect(criteria).to eq(subject) }
  it { expect(criteria.function).to eq(function) }
  it { expect(criteria.argument).to eq(argument) }
  it { expect(criteria.to_s).to eq(to_s) }
end

shared_examples 'an operator-function criterium' do |function, operator, value, to_s|
  it { expect(criteria).to eq(subject) }
  it { expect(criteria.function).to eq(function) }
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
      it_behaves_like 'an operator criterium', :eq, 'Bread', "Name eq 'Bread'"
    end

    describe '#ne' do
      let(:criteria) { subject.ne('Bread') }

      it { expect(subject).to respond_to(:ne) }
      it_behaves_like 'an operator criterium', :ne, 'Bread', "Name ne 'Bread'"
    end

    describe '#gt' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.gt(5) }

      it { expect(subject).to respond_to(:gt) }
      it_behaves_like 'an operator criterium', :gt, 5, "Age gt 5"
    end

    describe '#ge' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.ge(5) }

      it { expect(subject).to respond_to(:ge) }
      it_behaves_like 'an operator criterium', :ge, 5, 'Age ge 5'
    end

    describe '#lt' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.lt(5) }

      it { expect(subject).to respond_to(:lt) }
      it_behaves_like 'an operator criterium', :lt, 5, 'Age lt 5'
    end

    describe '#le' do
      let(:subject) { OData::Query::Criteria.new(property: integer_property) }
      let(:criteria) { subject.le(5) }

      it { expect(subject).to respond_to(:le) }
      it_behaves_like 'an operator criterium', :le, 5, 'Age le 5'
    end
  end

  describe 'string functions' do
    describe '#contains' do
      let(:criteria) { subject.contains('freds') }

      it { expect(subject).to respond_to(:contains) }
      it_behaves_like 'a function criterium', :contains, 'freds', "contains(Name,'freds')"
    end

    describe '#startswith' do
      let(:criteria) { subject.startswith('Alfreds') }

      it { expect(subject).to respond_to(:startswith) }
      it_behaves_like 'a function criterium', :startswith, 'Alfreds', "startswith(Name,'Alfreds')"
    end

    describe '#endswith' do
      let(:criteria) { subject.endswith('Futterkiste') }

      it { expect(subject).to respond_to(:endswith) }
      it_behaves_like 'a function criterium', :endswith, 'Futterkiste', "endswith(Name,'Futterkiste')"
    end

    describe '#tolower' do
      let(:criteria) { subject.tolower.eq('alfreds futterkiste') }

      it { expect(subject).to respond_to(:tolower) }
      it_behaves_like 'an operator-function criterium', :tolower, :eq, 'alfreds futterkiste', "tolower(Name) eq 'alfreds futterkiste'"
    end

    describe '#toupper' do
      let(:criteria) { subject.toupper.eq('ALFREDS FUTTERKISTE') }

      it { expect(subject).to respond_to(:toupper) }
      it_behaves_like 'an operator-function criterium', :toupper, :eq, 'ALFREDS FUTTERKISTE', "toupper(Name) eq 'ALFREDS FUTTERKISTE'"
    end
  end
end
