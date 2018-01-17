module OData4
  class Railtie < Rails::Railtie
    config.before_initialize do
      ::OData4::Railtie.load_configuration!
      ::OData4::Railtie.setup_service_registry!
    end

    # Looks for config/odata.yml and loads the configuration.
    def self.load_configuration!
      # TODO Implement Rails configuration loading
    end

    # Examines the loaded configuration and populates the
    # OData4::ServiceRegistry accordingly.
    def self.setup_service_registry!
      # TODO Populate OData4::ServiceRegistry based on configuration
    end
  end
end