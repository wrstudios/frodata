# frozen_string_literal: true

module Frodo
  class AbstractClient
    include Frodo::Concerns::Base
    include Frodo::Concerns::Connection
    include Frodo::Concerns::Authentication
    include Frodo::Concerns::Caching
    include Frodo::Concerns::API
  end
end
