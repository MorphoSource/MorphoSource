# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
module Hyrax
  class CulturalHeritageObjectPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :aat_attribute, :aat_attribute_label, :aat_material, :aat_material_label, :aat_period,
      :aat_period_label, :aat_type, :aat_type_label, :address, :bibliographic_citation,
      :catalog_number, :cho_attribute, :cho_type, :city, :collection_code, :context, :country,
      :current_location, :dating_method, :dimensions, :formation, :geographic_coordinates,
      :institution_code, :material, :numeric_time, :original_location, :periodic_time,
      :periodic_time_label, :provenance_date, :provenance_details, :provenance_location,
      :provenance_name, :short_title, :state_province, :tgn, :tgn_label, :vouchered,
      :public_media_ids,
      to: :solr_document

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
      'Object collection/creation date'
    end

    def creator_label
      'Object collector/creator'
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

    def showcase_identifiers_and_external_links_partial
      'showcase_identifiers_and_external_links'
    end

    def showcase_time_and_place_details_partial
      'showcase_time_and_place_details'
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

    def object_material
      (Array(aat_material_label) + Array(material)).compact.sort_by{|t| t.downcase}
    end

    def object_period
      (Array(aat_period_label) + Array(periodic_time)).compact.sort_by{|t| t.downcase}
    end

    def object_type
      (Array(aat_type_label) + Array(cho_type)).compact.sort_by{|t| t.downcase}
    end

    def object_attributes
      (Array(aat_attribute_label) + Array(cho_attribute)).compact.sort_by{|t| t.downcase}
    end

  end
end
