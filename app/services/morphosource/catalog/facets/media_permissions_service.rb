module Morphosource
  module Catalog
    module Facets
      class MediaPermissionsService < Morphosource::Works::PermissionsService

        def self.ids_for_media_facets(ability:)
          media_ids_for_view(ability: ability) | public_media_ids
        end

        # returns all public collections
        def self.public_media_ids
          query = ["has_model_ssim:Media AND visibility_ssi:open"]
          ActiveFedora::SolrService.query(query, fl: 'id', rows: 999999).map { |hit| hit['id']}
        end
      end
    end
  end
end
