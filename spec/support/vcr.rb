require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :faraday
  c.default_cassette_options = { record: :new_episodes }
  c.debug_logger = File.open(ENV['VCR_LOG'], 'w') if ENV['VCR_LOG']
  c.configure_rspec_metadata!
end
