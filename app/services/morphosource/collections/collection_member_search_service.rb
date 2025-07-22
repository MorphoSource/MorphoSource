# frozen_string_literal: true
module Morphosource
  module Collections
    class CollectionMemberSearchService < Hyrax::Collections::CollectionMemberSearchService

      private

      def std_core_fq
        "#{ActiveFedora.index_field_mapper.solr_name('member_of_collection_ids', :symbol)}:#{collection.id}"
      end
    end
  end
end
