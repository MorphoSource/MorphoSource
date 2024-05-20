module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    include ActionView::Helpers::UrlHelper

    attr_reader :total_po, :po_ids_by_org

    delegate :title, :organization_type, :institution_name, :institution_code, :collection_code, :recordset_id, :related_url, :address, :city, :state_province, :postal_code, :country, :contact_person, :team_id, :member_ids, :has_model, to: :solr_document

    def search_form_url
      Rails.application.routes.url_helpers.show_organization_path(solr_document.id)
    end

    def browse_service
      @browse_service ||= Morphosource::BrowseService.new
    end

    def total_devices
      @total_devices ||= organization_device_count + organization_collection_device_count
    end

    # Will soon be deprecated in favor of organization_collection_device_count as Organizations become legacy
    def organization_device_count
      member_ids.count
    end

    def organization_collection_device_count
      ActiveFedora::SolrService.count(%{
          has_model_ssim:Device AND 
          device_organization_id_ssim:#{id}
          #{member_ids.present? ? "AND -id:(#{member_ids.join(' OR ')})" : ""} 
        }
      )
    end

    def total_media
      @total_media || begin
        @total_media, @total_po = browse_service.total_media_and_po_by_org(solr_document.id)
        @total_media
      end
    end

    def total_po
      @total_po ||= begin
        @total_media, @total_po = browse_service.total_media_and_po_by_org(solr_document.id)
        @total_po
      end
    end

    # displays on catalog index
    def linked_team
      return if team_id.blank?
      team = ::SolrDocument.find(team_id.first)
      link_to team.title.first, Rails.application.routes.url_helpers.team_path(team.id)
    end
  end
end
