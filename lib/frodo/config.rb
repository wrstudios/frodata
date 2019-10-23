# frozen_string_literal: true

require 'logger'

module Frodo
  class << self
    attr_writer :log

    # Returns the current Configuration
    #
    # Example
    #
    #    Frodo.configuration.username = "username"
    #    Frodo.configuration.password = "password"
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the Configuration
    #
    # Example
    #
    #    Frodo.configure do |config|
    #      config.username = "username"
    #      config.password = "password"
    #    end
    def configure
      yield configuration
    end

    def log?
      @log ||= false
    end

    def log(message)
      return unless Frodo.log?
      configuration.logger.send(configuration.log_level, message)
    end
  end

  class Configuration
    class Option
      attr_reader :configuration, :name, :options

      def self.define(*args)
        new(*args).define
      end

      def initialize(configuration, name, options = {})
        @configuration = configuration
        @name = name
        @options = options
        @default = options.fetch(:default, nil)
      end

      def define
        write_attribute
        define_method if default_provided?
        self
      end

      private

      attr_reader :default
      alias default_provided? default

      def write_attribute
        configuration.send :attr_accessor, name
      end

      def define_method
        our_default = default
        our_name    = name
        configuration.send :define_method, our_name do
          instance_variable_get(:"@#{our_name}") ||
            instance_variable_set(
              :"@#{our_name}",
              our_default.respond_to?(:call) ? our_default.call : our_default
            )
        end
      end
    end

    class << self
      attr_accessor :options

      def option(*args)
        option = Option.define(self, *args)
        (self.options ||= []) << option.name
      end
    end

    # The OAuth client id
    option :client_id

    # The OAuth client secret
    option :client_secret

    option :host, default: 'login.microsoftonline.com'

    option :oauth_token
    option :refresh_token
    option :instance_url
    option :base_path

    # Set this to an object that responds to read, write and fetch and all GET
    # requests will be cached.
    option :cache

    # The number of times reauthentication should be tried before failing.
    option :authentication_retries, default: 3

    # Set to true if you want responses from Dynamics to be gzip compressed.
    option :compress

    # Faraday request read/open timeout.
    option :timeout

    # Faraday adapter to use. Defaults to Faraday.default_adapter.
    option :adapter, default: lambda { Faraday.default_adapter }

    option :proxy_uri, default: lambda { ENV['FRODATA_PROXY_URI'] }

    # A Proc that is called with the response body after a successful authentication.
    option :authentication_callback

    # Set SSL options
    option :ssl, default: {}

    # A Hash that is converted to HTTP headers
    option :request_headers

    # Set a logger for when Frodo.log is set to true, defaulting to STDOUT
    option :logger, default: ::Logger.new(STDOUT)

    # Set a log level for logging when Frodo.log is set to true, defaulting to :debug
    option :log_level, default: :debug

    # Optionally set the navigation properties to improve performance of the client
    option :navigation_properties

    def options
      self.class.options
    end
  end
end
