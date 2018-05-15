module FrOData
  class Query
    module InBatches
      DEFAULT_BATCH_SIZE = 10

      # Process results in batches.
      #
      # When a block is given, yields `FrOData::Query::Result`
      # objects of specified batch size to the block.
      #
      #   service['Products'].query.in_batches(of: 10) do |batch|
      #     batch.count # batch size (10 except for last batch)
      #     batch.is_a? FrOData::Query::Result # true
      #   end
      #
      # Returns an Enumerator to process results individually.
      #
      #   service['Products'].query.in_batches.each do |entity|
      #     entity.is_a? FrOData::Entity # true
      #   end
      #
      # @param of: [int] batch size
      # @return [Enumerator]
      def in_batches(of: DEFAULT_BATCH_SIZE, &block)
        per_page = of

        if block_given?
          each_batch(of, &block)
        else
          Enumerator.new do |result|
            each_batch(of) do |batch|
              batch.each { |entity| result << entity }
            end
          end
        end
      end

      private

      def each_batch(per_page, &block)
        page = 0

        loop do
          batch = get_paginated_entities(per_page, page)
          break if batch.empty?

          yield batch

          page += 1
        end
      end

      def get_paginated_entities(per_page, page)
        skip(per_page * page).limit(per_page).execute
      end
    end
  end
end
