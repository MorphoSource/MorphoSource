# Generated via
#  `rails generate hyrax:work EngineeringObject`
module Hyrax
  class EngineeringObjectPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :institution_code, :catalog_number, :desription, :is_pak, :anonymize_origin, :anonymize_meta_data, :is_built_in_fiducials_present, :snl_assembler, :assembly_date, :preparation_notes, to: :solr_document

    def related_media_ids 
      ids = solr_document.related_media_ids.present? ? solr_document.related_media_ids : []
      return ids
    end

    def viewable_related_media_ids 
      return related_media_ids if current_ability.current_user.admin?
      filtered_ids = []
      related_media_ids.each do |id|
        if current_ability.can?(:read, id) 
          filtered_ids << id
        end
      end
      return filtered_ids
    end

    def anonymize_origin?
      anonymize_origin && anonymize_origin.first == 'Anonymize Origin'
    end

    def anonymize_meta_data?
      anonymize_meta_data && anonymize_meta_data.first == 'Anonymize Meta Data'
    end

    def date_created_label
      'Engineeting Object Creation Date'
    end

    def creator_label
      'Engineering Object Creator'
    end

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
