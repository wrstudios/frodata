module Frodo
  class Railtie < Rails::Railtie
    config.before_initialize do
      ::Frodo::Railtie.load_configuration!
      ::Frodo::Railtie.setup_service_registry!
    end

    # Looks for config/odata.yml and loads the configuration.
    def self.load_configuration!
      # TODO Implement Rails configuration loading
    end

    # Examines the loaded configuration and populates the
    # Frodo::ServiceRegistry accordingly.
    def self.setup_service_registry!
      # TODO Populate Frodo::ServiceRegistry based on configuration
    end
  end
end