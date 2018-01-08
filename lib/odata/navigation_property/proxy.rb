module OData
  class NavigationProperty
    class Proxy
      def initialize(entity)
        @entity = entity
      end

      def [](association_name)
        if associations[association_name].nil?
          raise ArgumentError, "unknown association: #{association_name}"
        elsif entity.links[association_name].nil?
          association = associations[association_name]
          if association.nav_type == :collection
            []
          else
            nil
          end
        else
          association_results(association_name)
        end
      end

      def size
        associations.size
      end

      private

      attr_reader :entity

      def service
        @service ||= OData::ServiceRegistry[entity.service_name]
      end

      def namespace
        @namespace ||= service.namespace
      end

      def entity_type
        @entity_type ||= entity.name
      end

      def associations
        @associations ||= service.navigation_properties[entity_type]
      end

      def association_results(association_name)
        association = associations[association_name]
        link = entity.links[association_name]

        raise "Invalid navigation link for #{association_name}" unless link[:href]

        options = {
          type:         association.entity_type,
          namespace:    namespace,
          service_name: entity.service_name
        }
        entity_set = Struct.new(:service, :entity_options)
                           .new(entity.service, options)

        query = OData::Query.new(entity_set)
        result = query.execute(link[:href])

        if association.nav_type == :collection
          result
        else
          result.first
        end
      end
    end
  end
end
