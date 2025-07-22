# frozen_string_literal: true
module Morphosource
  module Collections
    class CollectionMemberSearchService < Hyrax::Collections::CollectionMemberSearchService

      private

      def prepare_media_query_fq_param(initial, new, new_core)
        ((initial.map { |x| x == std_core_fq && new_core.present? ? new_core : x }) + new).uniq
      end

      def std_core_fq
        "#{ActiveFedora.index_field_mapper.solr_name('member_of_collection_ids', :symbol)}:#{collection.id}"
      end
    end
  end
end
