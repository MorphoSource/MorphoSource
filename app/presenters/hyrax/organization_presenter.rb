module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    include ActionView::Helpers::UrlHelper

    attr_reader :total_po, :po_ids_by_org

    delegate :title, :organization_type, :institution_name, :institution_code, :collection_code, :recordset_id, :related_url, :address, :city, :state_province, :country, :contact_person, :team_id, :member_ids, to: :solr_document

    def search_form_url
      Rails.application.routes.url_helpers.show_organization_path(solr_document.id)
    end

    def browse_service
      @browse_service ||= Morphosource::BrowseService.new
    end
    
    def total_po
      if member_ids.present?
        return browse_service.total_po_by_org(solr_document.id)
      else
        return 0
      end
    end

    def total_media
      if member_ids.present?
      	return browse_service.total_media_by_org(solr_document.id)
      else
      	return 0
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
