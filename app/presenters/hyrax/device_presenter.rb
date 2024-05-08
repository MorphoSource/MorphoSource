# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :modality, :ark, :organization_id, to: :solr_document

    #
    # Modality (return one more more values)
    #
    # @return [Array] modality
    #
    def device_modality
      @device_modality ||= modality.map{ |m| Morphosource::ModalitiesService.new.label(m) }
    end

    def related_media_ids
      @related_media_ids ||= begin
#        solr_document.related_media_ids || []
      end
    end

    def viewable_related_media_ids
      return related_media_ids if current_ability.current_user.admin?
      @viewable_related_media_ids ||= related_media_ids.select { |id| current_ability.can?(:read, id) }
    end

    # methods for showcase partials
    def showcase_work_title_partial
      'showcase_work_title'
    end

    def showcase_show_actions_partial
      'showcase_show_actions'
    end

    def showcase_general_details_partial
      'showcase_general_details'
    end

    def showcase_media_items_partial
      'showcase_media_items'
    end

    def showcase_media_items_member_partial
      '/hyrax/physical_objects/showcase_media_items_member'
    end

  end
end
