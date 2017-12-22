require 'odata'
require 'rspec/matchers' # required for 'equivalent-xml'
require 'equivalent-xml'
require 'securerandom'
require 'timecop'

# Load all files from `spec/support`
Dir["support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 3
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.after(:example) do
    # We're calling this as a private method because there should not be any
    # reasons to have to flush the service registry except in testing.
    OData::ServiceRegistry.instance.send(:flush)
  end
end
