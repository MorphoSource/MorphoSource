# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  class CulturalHeritageObjectPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number, :collection_code, :numeric_time, :original_location,
             :periodic_time, :vouchered, :cho_type, :material, :short_title, :geographic_coordinates, to: :solr_document

    # methods for showcase partials
    def showcase_work_title_partial
      'showcase_work_title'
    end

    def showcase_show_actions_partial
      '/hyrax/physical_objects/showcase_show_actions'
    end

    def showcase_preview_image_partial
      'showcase_preview_image'
    end

    def showcase_general_details_partial
      'showcase_general_details'
    end

    def showcase_taxonomy_partial
      'showcase_taxonomy'
    end

    def showcase_identifiers_and_external_links_partial
      'showcase_identifiers_and_external_links'
    end

    def showcase_time_and_place_details_partial
      '/hyrax/physical_objects/showcase_time_and_place_details'
    end

    def showcase_bibliographic_citations_partial
      '/hyrax/physical_objects/showcase_bibliographic_citations'
    end

    def showcase_media_items_partial
      '/hyrax/physical_objects/showcase_media_items'
    end

    def showcase_media_items_member_partial
      '/hyrax/physical_objects/showcase_media_items_member'
    end

    def showcase_collections_partial
      '/hyrax/physical_objects/showcase_collections'
    end

    def showcase_tags_partial
      '/hyrax/physical_objects/showcase_tags'
    end

    def showcase_citation_and_download_partial
      '/hyrax/physical_objects/showcase_citation_and_download'
    end

  end
end
