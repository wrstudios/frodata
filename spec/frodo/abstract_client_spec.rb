# frozen_string_literal: true

require 'spec_helper'

describe Frodo::AbstractClient do
  subject { described_class }

  it { should < Frodo::Concerns::Base }
  it { should < Frodo::Concerns::Connection }
  it { should < Frodo::Concerns::Authentication }
  it { should < Frodo::Concerns::Caching }
  it { should < Frodo::Concerns::API }
end
