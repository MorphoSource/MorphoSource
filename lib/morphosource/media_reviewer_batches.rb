# frozen_string_literal: true

module Morphosource
  # Temporary enumeration shared by the Media reviewer backfill, verification and reindex.
  module MediaReviewerBatches
    BATCH_SIZE = 500

    # Solr supplies ids only; callers load authoritative metadata from Fedora.
    # @yieldparam ids [Array<String>] one batch, ordered by the unique id
    def self.each
      cursor = '*'
      solr = Morphosource::SolrService.new

      loop do
        result = solr.get('has_model_ssim:Media', fl: 'id', rows: BATCH_SIZE,
                                               sort: 'id asc', cursorMark: cursor)
        yield result.fetch('response').fetch('docs').map { |doc| doc.fetch('id') }

        next_cursor = result.fetch('nextCursorMark')
        break if next_cursor == cursor

        cursor = next_cursor
      end
    end
  end
end
