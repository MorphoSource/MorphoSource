module Morphosource
  module Catalog
    module Facets
      class CollectionsPermissionsService < Hyrax::Collections::PermissionsService

        def self.ids_for_collection_facet(ability:)
          collection_ids_for_view(ability: ability) | public_collection_ids
        end

        # returns all public collections
        def self.public_collection_ids
          query = ["has_model_ssim:Collection AND visibility_ssi:open"]
          ActiveFedora::SolrService.query(query, fl: 'id', rows: 999999).map { |hit| hit['id']}
        end

        private

        # returns collections user has been granted access to view through user or group access grants
        # def self.visible_collection_ids(ability)
        #   self.collection_ids_for_view(ability: ability)
        # end
      end
    end
  end
end
