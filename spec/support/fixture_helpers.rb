# frozen_string_literal: true

module FixtureHelpers
    module InstanceMethods

      def fixture(f)
        File.read(File.expand_path("../../fixtures/#{f}.json", __FILE__))
      end
    end
  end

  RSpec.configure do |config|
    config.include FixtureHelpers::InstanceMethods
  end
