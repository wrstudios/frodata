# frozen_string_literal: true

module FrOData
  class AbstractClient
    include FrOData::Concerns::Base
    include FrOData::Concerns::Connection
    include FrOData::Concerns::Authentication
    include FrOData::Concerns::Caching
    include FrOData::Concerns::API
  end
end
