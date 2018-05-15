module FrOData
  class NavigationProperty
    class Proxy
      def initialize(entity, nav_name)
        @entity = entity
        @nav_name = nav_name
      end

      def value=(value)
        @value = value
      end

      def value
        if link.nil?
          if nav_property.nav_type == :collection
            []
          else
            nil
          end
        else
          @value ||= fetch_result
        end
      end

      private

      attr_reader :entity, :nav_name

      def service
        @service ||= FrOData::ServiceRegistry[entity.service_name]
      end

      def namespace
        @namespace ||= service.namespace
      end

      def schema
        @schema ||= service.schemas[namespace]
      end

      def entity_type
        @entity_type ||= entity.name
      end

      def link
        entity.links[nav_name]
      end

      def nav_property
        schema.navigation_properties[entity_type][nav_name]
      end

      def fetch_result
        raise "Invalid navigation link for #{nav_name}" unless link[:href]

        options = {
          type:         nav_property.entity_type,
          namespace:    namespace,
          service_name: entity.service_name
        }
        entity_set = Struct.new(:service, :entity_options)
                           .new(entity.service, options)

        query = FrOData::Query.new(entity_set)
        begin
          result = query.execute(link[:href])
        rescue => ex
          raise ex unless ex.message =~ /Not Found/
          result = []
        end

        if nav_property.nav_type == :collection
          result
        else
          result.first
        end
      end
    end
  end
end
