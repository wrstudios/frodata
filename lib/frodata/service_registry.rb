require 'singleton'

module FrOData
  # Provides a registry for keeping track of multiple FrOData::Service instances
  class ServiceRegistry
    include Singleton

    # Add a service to the Registry
    #
    # @param service [FrOData::Service] service to add to the registry
    def add(service)
      initialize_instance_variables
      @services << service if service.is_a?(FrOData::Service) && !@services.include?(service)
      @services_by_name[service.name] = @services.find_index(service)
      @services_by_url[service.service_url] = @services.find_index(service)
    end

    # Lookup a service by URL or name
    #
    # @param lookup_key [String] the URL or name to lookup
    # @return [FrOData::Service, nil] the FrOData::Service or nil
    def [](lookup_key)
      initialize_instance_variables
      index = @services_by_name[lookup_key] || @services_by_url[lookup_key]
      index.nil? ? nil : @services[index]
    end

    # (see #add)
    def self.add(service)
      FrOData::ServiceRegistry.instance.add(service)
    end

    # (see #[])
    def self.[](lookup_key)
      FrOData::ServiceRegistry.instance[lookup_key]
    end

    private

    def initialize_instance_variables
      @services ||= []
      @services_by_name ||= {}
      @services_by_url ||= {}
    end

    def flush
      @services = []
      @services_by_name = {}
      @services_by_url = {}
    end
  end
end