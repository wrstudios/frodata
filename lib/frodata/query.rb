require 'frodata/query/criteria'
require 'frodata/query/in_batches'

module FrOData
  # FrOData::Query provides the query interface for requesting Entities matching
  # specific criteria from an FrOData::EntitySet. This class should not be
  # instantiated directly, but can be. Normally you will access a Query by
  # first asking for one from the FrOData::EntitySet you want to query.
  class Query
    attr_reader :options

    include InBatches

    # Create a new Query for the provided EntitySet
    # @param entity_set [FrOData::EntitySet]
    # @param options [Hash] Query options
    def initialize(entity_set, options = {})
      @entity_set = entity_set
      @options    = options
      setup_empty_criteria_set
    end

    # Instantiates an FrOData::Query::Criteria for the named property.
    # @param property [to_s]
    def [](property)
      property_instance = @entity_set.new_entity.get_property(property)
      property_instance = property if property_instance.nil?
      FrOData::Query::Criteria.new(property: property_instance)
    end

    # Find the Entity with the supplied key value.
    # @param key [to_s] primary key to lookup
    # @return [FrOData::Entity,nil]
    def find(key)
      entity = @entity_set.new_entity
      key_property = entity.get_property(entity.primary_key)
      key_property.value = key

      pathname = "#{entity_set.name}(#{key_property.url_value})"
      query = [pathname, assemble_criteria].compact.join('?')
      execute(query).first
    end

    # Adds a filter criteria to the query.
    # For filter syntax see https://msdn.microsoft.com/en-us/library/gg309461.aspx
    # Syntax:
    #   Property Operator Value
    #
    # For example:
    #   Name eq 'Customer Service'
    #
    # Operators:
    # eq, ne, gt, ge, lt, le, and, or, not
    #
    # Value
    #  can be 'null', can use single quotes
    # @param criteria
    def where(criteria)
      criteria_set[:filter] << criteria
      self
    end

    # Adds a fulltext search term to the query
    # NOTE: May not be implemented by the service
    # @param term [String]
    def search(term)
      criteria_set[:search] << term
      self
    end

    # Adds a filter criteria to the query with 'and' logical operator.
    # @param criteria
    #def and(criteria)
    #
    #end

    # Adds a filter criteria to the query with 'or' logical operator.
    # @param criteria
    #def or(criteria)
    #
    #end

    # Specify properties to order the result by.
    # Can use 'desc' like 'Name desc'
    # @param properties [Array<Symbol>]
    # @return [self]
    def order_by(*properties)
      criteria_set[:orderby] += properties
      self
    end

    # Specify associations to expand in the result.
    # @param associations [Array<Symbol>]
    # @return [self]
    def expand(*associations)
      criteria_set[:expand] += associations
      self
    end

    # Specify properties to select within the result.
    # @param properties [Array<Symbol>]
    # @return [self]
    def select(*properties)
      criteria_set[:select] += properties
      self
    end

    # Add skip criteria to query.
    # @param value [to_i]
    # @return [self]
    def skip(value)
      criteria_set[:skip] = value.to_i
      self
    end

    # Add limit criteria to query.
    # @param value [to_i]
    # @return [self]
    def limit(value)
      criteria_set[:top] = value.to_i
      self
    end

    # Add inline count criteria to query.
    # Not Supported in CRM2011
    # @return [self]
    def include_count
      criteria_set[:inline_count] = true
      self
    end

    # Convert Query to string.
    # @return [String]
    def to_s
      criteria = params.map { |k, v| "#{k}=#{v}" }.join('&')
      [entity_set.name, params.any? ? criteria : nil].compact.join('?')
    end

    # Execute the query.
    # @return [FrOData::Service::Response]
    def execute(url_chunk = entity_set.name, params = assemble_criteria)
      service.execute(url_chunk, options.merge(query: self, params: params))
    end

    # Executes the query to get a count of entities.
    # @return [Integer]
    def count
      response = self.execute("#{entity_set.name}/$count")
      # Some servers (*cough* Microsoft *cough*) seem to
      # return extraneous characters in the response.
      response.body.scan(/\d+/).first.to_i
    end

    # Checks whether a query will return any results by calling #count
    # @return [Boolean]
    def empty?
      self.count == 0
    end

    # The EntitySet for this query.
    # @return [FrOData::EntitySet]
    # @api private
    def entity_set
      @entity_set
    end

    # The parameter hash for this query.
    # @return [Hash] Params hash
    def params
      assemble_criteria || {}
    end

    # The service for this query
    # @return [FrOData::Service]
    # @api private
    def service
      @service ||= entity_set.service
    end

    private

    attr_reader :criteria_set

    def setup_empty_criteria_set
      @criteria_set = {
        filter:       [],
        search:       [],
        select:       [],
        expand:       [],
        orderby:      [],
        skip:         0,
        top:          0,
        inline_count: false
      }
    end

    def assemble_criteria
      [
        filter_criteria,
        search_criteria,
        list_criteria(:orderby),
        list_criteria(:expand),
        list_criteria(:select),
        inline_count_criteria,
        paging_criteria(:skip),
        paging_criteria(:top)
      ].compact.reduce(&:merge)
    end

    def filter_criteria
      return nil if criteria_set[:filter].empty?
      filters = criteria_set[:filter].collect(&:to_s)
      { '$filter' => filters.join(' and ') }
    end

    def search_criteria
      return nil if criteria_set[:search].empty?
      filters = criteria_set[:search].collect(&:to_s)
      { '$search' => filters.join(' AND ') }
    end

    def list_criteria(name)
      return nil if criteria_set[name].empty?
      { "$#{name}" => criteria_set[name].join(',') }
    end

    # inlinecount not supported by Microsoft CRM 2011
    def inline_count_criteria
      criteria_set[:inline_count] ? { '$count' => 'true' } : nil
    end

    def paging_criteria(name)
      criteria_set[name] == 0 ? nil : { "$#{name}" => criteria_set[name] }
    end
  end
end
