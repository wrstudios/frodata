module FrOData
  class Railtie < Rails::Railtie
    config.before_initialize do
      ::FrOData::Railtie.load_configuration!
      ::FrOData::Railtie.setup_service_registry!
    end

    # Looks for config/odata.yml and loads the configuration.
    def self.load_configuration!
      # TODO Implement Rails configuration loading
    end

    # Examines the loaded configuration and populates the
    # FrOData::ServiceRegistry accordingly.
    def self.setup_service_registry!
      # TODO Populate FrOData::ServiceRegistry based on configuration
    end
  end
end