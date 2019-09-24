# frozen_string_literal: true
require 'erb'
require 'uri'
require 'frodo/concerns/verbs'

module Frodo
  module Concerns
    module API
      extend Frodo::Concerns::Verbs

      # Public: Helper methods for performing arbitrary actions against the API using
      # various HTTP verbs.
      #
      # Examples
      #
      #   # Perform a get request
      #   client.get '/api/data/v9.1/leads'
      #   client.api_get 'leads'
      #
      #   # Perform a post request
      #   client.post '/api/data/v9.1/leads', { ... }
      #   client.api_post 'leads', { ... }
      #
      #   # Perform a put request
      #   client.put '/api/data/v9.1/leads(073ca9c8-2a41-e911-a81d-000d3a1d5a0b)', { ... }
      #   client.api_put 'leads(073ca9c8-2a41-e911-a81d-000d3a1d5a0b)', { ... }
      #
      #   # Perform a delete request
      #   client.delete '/api/data/v9.1/leads(073ca9c8-2a41-e911-a81d-000d3a1d5a0b)'
      #   client.api_delete 'leads(073ca9c8-2a41-e911-a81d-000d3a1d5a0b)'
      #
      # Returns the Faraday::Response.
      define_verbs :get, :post, :put, :delete, :patch, :head

      # Public: Return the metadata XML schema for the service
      #
      # Returns [String]
      def metadata
        api_get("$metadata").body
      end

      def metadata_on_init
        # Creating Metadata using a different client than the one that is stored
        Frodo::Client.new(@options).api_get("$metadata").body
      end

      # Public: Execute a query and returns the result.
      #
      # Query can be the url_chunk per the OData V4 spec or
      # a Frodo::Query. The latter being preferred
      #
      # Examples
      #
      #   # Find the names of all Accounts
      #   client.query("leads?$filter=firstname eq 'yo'")
      #
      # or
      #
      #   query = client.service['leads'].query
      #   query.where("firstname eq 'yo'")
      #   client.query(query)
      #
      # Returns a list of Frodo::Entity
      def query(query)
        url_chunk, entity_set = if query.is_a?(Frodo::Query)
                      [query.to_s, query.entity_set.name]
                    else
                      [query]
                    end

        body = api_get(url_chunk).body

        # if manual query as a string we detect the set on the response
        entity_set = body['@odata.context'].split('#')[-1] if entity_set.nil?
        build_entity(entity_set, body)
      end

      # Public: Insert a new record.
      #
      # entity_set - The set the entity belongs to
      # attrs   - Hash of attributes to set on the new record.
      #
      # Examples
      #
      #   # Add a new lead
      #   client.create('leads', {"firstname" =>'Bob'})
      #   # => '073ca9c8-2a41-e911-a81d-000d3a1d5a0b'
      #
      # Returns the primary key value of the newly created entity.
      # Returns false if something bad happens.
      def create(*args)
        create!(*args)
      rescue *exceptions
        false
      end
      alias insert create

      # Public: Insert a new record.
      #
      # entity_set_name - The set the entity belongs to
      # attrs   - Hash of attributes to set on the new record.
      #
      # Examples
      #
      #   # Add a new lead
      #   client.create!('leads', {"firstname" =>'Bob'})
      #   # => '073ca9c8-2a41-e911-a81d-000d3a1d5a0b'
      #
      # Returns the primary key value of the newly created entity.
      # Raises exceptions if an error is returned from Dynamics.
      def create!(entity_set_name, attrs)
        entity_set = service[entity_set_name]
        url_chunk = entity_set_to_url_chunk(entity_set)
        url = api_post(url_chunk, attrs).headers['odata-entityid']
        id_match = url.match(/\((.+)\)/)
        if id_match.nil?
          raise Frodo::Error.new "entity url not in expected format: #{url.inspect}"
        end
        return id_match[1]
      end
      alias insert! create!

      # Public: Update a record.
      #
      # entity_set - The set the entity belongs to
      # attrs   - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Update the lead with id '073ca9c8-2a41-e911-a81d-000d3a1d5a0b'
      #   client.update('leads', "leadid": '073ca9c8-2a41-e911-a81d-000d3a1d5a0b', Name: 'Whizbang Corp')
      #
      # Returns true if the entity was successfully updated.
      # Returns false if there was an error.
      def update(*args)
        update!(*args)
      rescue *exceptions
        false
      end

      # Public: Update a record.
      #
      # entity_set - The set the entity belongs to
      # attrs   - Hash of attributes to set on the record.
      #
      # Examples
      #
      #   # Update the leads with id '073ca9c8-2a41-e911-a81d-000d3a1d5a0b'
      #   client.update!('leads', 'leadid' => '073ca9c8-2a41-e911-a81d-000d3a1d5a0b', "firstname" => 'Whizbang Corp')
      #
      # Returns true if the entity was successfully updated.
      # Raises an exception if an error is returned from Dynamics.
      def update!(entity_set, attrs, additional_headers={})
        entity = service[entity_set].new_entity(attrs)
        url_chunk = to_url_chunk(entity)

        raise ArgumentError, 'ID field missing from provided attributes' if entity.is_new?

        api_patch url_chunk, attrs do |req|
          req.headers.merge!(additional_headers)
        end
        true
      end

      # Public: Delete a record.
      #
      # entity_set - The set the entity belongs to
      # id      - The Dynamics primary key ID of the record.
      #
      # Examples
      #
      #   # Delete the lead with id  "073ca9c8-2a41-e911-a81d-000d3a1d5a0b"
      #   client.destroy('leads',  "073ca9c8-2a41-e911-a81d-000d3a1d5a0b")
      #
      # Returns true if the entity was successfully deleted.
      # Returns false if an error is returned from Dynamics.
      def destroy(*args)
        destroy!(*args)
      rescue *exceptions
        false
      end

      # Public: Delete a record.
      #
      # entity_set - The set the entity belongs to
      # id      - The Dynamics primary key ID of the record.
      #
      # Examples
      #
      #   # Delete the lead with id  "073ca9c8-2a41-e911-a81d-000d3a1d5a0b"
      #   client.destroy!('leads',  "073ca9c8-2a41-e911-a81d-000d3a1d5a0b")
      #
      # Returns true of the entity was successfully deleted.
      # Raises an exception if an error is returned from Dynamics.
      def destroy!(entity_set, id)
        query = service[entity_set].query
        url_chunk = query.find(id).to_s
        api_delete url_chunk
        true
      end

      # Public: Finds a single record and returns all fields.
      #
      # entity_set - The set the entity belongs to
      # id      - The id of the record. If field is specified, id should be the id
      #           of the external field.
      #
      # Returns the Entity record.
      def find(entity_set, id)
        query = service[entity_set].query
        url_chunk = query.find(id)

        body = api_get(url_chunk).body
        build_entity(entity_set, body)
      end

      # Public: Finds a single record and returns select fields.
      #
      # entity_set - The set the entity belongs to
      # id      - The id of the record. If field is specified, id should be the id
      #           of the external field.
      # fields  - A String array denoting the fields to select.  If nil or empty array
      #           is passed, all fields are selected.
      def select(entity_set, id, fields)
        query = service[entity_set].query

        fields.each{|field| query.select(field)}
        url_chunk = query.find(id)

        body = api_get(url_chunk).body
        build_entity(entity_set, body)
      end

      # Public: Count the entity set or for the query passed
      #
      # entity_set or query  - A  String or a Frodo::Query. If String is passed,
      #                         all entities for the set are counted.
      def count(query)
        url_chunk = if query.is_a?(Frodo::Query)
                      query.include_count
                      query.to_s
                    else
                      service[query].query.count
                    end

        body = api_get(url_chunk).body

        if query.is_a?(Frodo::Query)
          body['@odata.count']
        else
          # Some servers (*cough* Microsoft *cough*) seem to return
          # extraneous characters in the response.
          # I found out that the _\xef\xbb\xbf  contains probably invisible junk characters
          # called the Unicode BOM (short name for: byte order mark).
          body.scan(/\d+/).first.to_i
        end
      end

      private

      # Internal: Returns a path to an api endpoint based on configured client
      #
      # Examples
      #
      #   api_path('leads')
      #   # => '/leads'
      def api_path(path)
        "#{options[:base_path]}/#{path}" || "/#{path}"
      end

      def build_entity(entity_set, data)
        entity_options = service[entity_set].entity_options
        single_entity?(data) ? parse_entity(data, entity_options) : parse_entities(data, entity_options)
      end

      def single_entity?(body)
        body['@odata.context'] =~ /\$entity$/
      end

      def parse_entity(entity_json, entity_options)
        Frodo::Entity.from_json(entity_json, entity_options)
      end

      def parse_entities(body, entity_options)
        body['value'].map  do |entity_data|
          Frodo::Entity.from_json(entity_data, entity_options)
        end
      end

      def to_url_chunk(entity)
        primary_key = entity.get_property(entity.primary_key).url_value
        set = entity.entity_set.name
        entity.is_new? ? set : "#{set}(#{primary_key})"
      end

      def entity_set_to_url_chunk(entity_set)
        return entity_set.name
      end

      # Internal: Errors that should be rescued from in non-bang methods
      def exceptions
        [Faraday::Error::ClientError]
      end
    end
  end
end
