# Generated via
#  `rails generate hyrax:work Device`
module Hyrax
  class DevicePresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :modality, :ark, :device_organization_id, :device_organization_title, to: :solr_document

    #
    # Modality (return one more more values)
    #
    # @return [Array] modality
    #
    def device_modality
      @device_modality ||= modality.map{ |m| Morphosource::ModalitiesService.new.label(m) }
    end

    def device_organization_link
      return '' if !device_organization_id.present?
      begin
        doc = ::SolrDocument.find(device_organization_id)
      rescue Blacklight::Exceptions::RecordNotFound
        return ''
      end
      case doc.has_model
      when ["Organization"]
        Rails.application.routes.url_helpers.hyrax_organization_path(device_organization_id)
      when ["OrganizationCollection"]
        Rails.application.routes.url_helpers.organization_collection_path(device_organization_id)
      else
        ''
      end
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
