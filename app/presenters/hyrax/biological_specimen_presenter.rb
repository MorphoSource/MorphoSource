# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
module Hyrax
  class BiologicalSpecimenPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :bibliographic_citation, :catalog_number,  :collection_code, :organization_code, :numeric_time, :original_location, :periodic_time, :vouchered, :idigbio_recordset_id, :idigbio_uuid, :is_type_specimen, :occurrence_id, :sex, :geographic_coordinates, :member_ids, to: :solr_document

    delegate :taxonomies, :canonical_taxonomy_object, :trusted_taxonomies, :user_taxonomies, to: :work

# TODO: remove below block later if not needed any more.
    #attr_accessor :organization_code, :organization_title, :organization_description, :organization_address, :#organization_city, :organization_state_province, :organization_country #
#
#    #def get_organization_data
#    #  organization = parent_organization
#    #  if organization.present?
#    #    if organization.organization_code.present?
#    #      @organization_code = organization.organization_code.first
#    #    end
#    #    if organization.title.present?
#    #      @organization_title = organization.title.first
#    #    end
#    #    if organization.description.present?
#    #      @organization_description = organization.description.first
#    #    end
#    #    if organization.address.present?
#    #      @organization_address = organization.address.first
#    #    end
#    #    if organization.city.present?
#    #      @organization_city = organization.city.first
#    #    end
#    #    if organization.state_province.present?
#    #      @organization_state_province = organization.state_province.first
#    #    end
#    #    if organization.country.present?
#    #      @organization_country = organization.country.first
#    #    end
#    #    
    #  end
    #end

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
