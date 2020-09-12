module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    attr_reader :total_po, :po_ids_by_org

    delegate :organization_type, :institution_name, :institution_code, :collection_code, :recordset_id, :address, :city, :state_province, :country, :contact_person, :team_id, :member_ids, to: :solr_document


	  def browse_service
	    @browse_service ||= Morphosource::BrowseService.new
	  end

	  def po_ids_by_org
	  	@po_ids_by_org ||= browse_service.po_ids_by_org(solr_document)
	  end

    def total_po
    	po_ids_by_org.length
    end

    def total_media
			if member_ids.present?
				return browse_service.total_media_by_po_ids(po_ids_by_org)
			else
				return 0
			end
    end

  end
end
