# frozen_string_literal: true

require 'spec_helper'

describe FrOData::AbstractClient do
  subject { described_class }

  it { should < FrOData::Concerns::Base }
  it { should < FrOData::Concerns::Connection }
  it { should < FrOData::Concerns::Authentication }
  it { should < FrOData::Concerns::Caching }
  it { should < FrOData::Concerns::API }
end
