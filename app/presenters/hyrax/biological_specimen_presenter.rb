# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  class BiologicalSpecimenPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number,  :collection_code, :institution_code, :numeric_time, :original_location, :periodic_time, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex, :geographic_coordinates, :member_ids, to: :solr_document

    delegate :taxonomies, :canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies, to: :work

    attr_accessor :institution_code, :institution_title, :institution_description, :institution_address, :institution_city, :institution_state_province, :institution_country 

    def get_institution_data
      institution = parent_institution
      if institution.present?
        if institution.institution_code.present?
          @institution_code = institution.institution_code.first
        end
        if institution.title.present?
          @institution_title = institution.title.first
        end
        if institution.description.present?
          @institution_description = institution.description.first
        end
        if institution.address.present?
          @institution_address = institution.address.first
        end
        if institution.city.present?
          @institution_city = institution.city.first
        end
        if institution.state_province.present?
          @institution_state_province = institution.state_province.first
        end
        if institution.country.present?
          @institution_country = institution.country.first
        end
        
      end
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
