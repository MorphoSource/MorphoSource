# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  class BiologicalSpecimenPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :address, :bibliographic_citation, :catalog_number, :city, :collection_code, :context, 
      :country, :dating_method, :dimensions, :formation, :institution_code, :numeric_time, 
      :original_location, :periodic_time, :provenance_details, :provenance_name, :state_province, 
      :tgn_label, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, 
      :occurrence_id, :sex, :geographic_coordinates, 
      to: :solr_document

    delegate :taxonomies, :taxonomies_titles, :canonical_taxonomy_object, :trusted_taxonomies, 
      :gbif_taxonomies, :user_taxonomies, 
      to: :work

    def related_media_ids
      @related_media_ids ||= begin
        solr_document.related_media_ids || []
      end
    end

    def viewable_related_media_ids
      return related_media_ids if current_ability.current_user.admin?
      @viewable_related_media_ids ||= related_media_ids.select { |id| current_ability.can?(:read, id) }
    end

    def date_created_label
      'Date Collected'
    end

    def creator_label
      'Object collector'
    end

    def canonical_taxonomy_label
      if canonical_taxonomy_object.present?
        if canonical_taxonomy_object.trusted == ["Yes"]
          return I18n.t('morphosource.taxonomy.labels.trusted_canonical')
        end
      end
      I18n.t('morphosource.taxonomy.labels.canonical')
    end

    def canonical_taxonomy_presenter
      Hyrax::TaxonomyPresenter.new(canonical_taxonomy_solr, current_ability, request)
    end

    def canonical_taxonomy_solr
      Taxonomy.find(work.canonical_taxonomy.first).to_solr
    end

    # methods for showcase partials
    def showcase_work_title_partial
      '/hyrax/physical_objects/showcase_work_title'
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

    def showcase_time_details_partial
      'showcase_time_details'
    end

    def showcase_location_details_partial
      'showcase_location_details'
    end

    def showcase_provenance_partial
      'showcase_provenance'
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
