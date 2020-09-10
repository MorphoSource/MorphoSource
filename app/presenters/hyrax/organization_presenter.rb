module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :organization_type, :institution_name, :institution_code, :collection_code, :recordset_id, :address, :city, :state_province, :country, :contact_person, :team_id, :member_ids, to: :solr_document


    def total_media
			if member_ids.present?
	      return ActiveFedora::Base.where("physical_object_id_tesim:(#{po_ids_by_org.join(' OR ')}) AND has_model_ssim:Media").count
			else
				return 0
			end
    end

    def total_po
			if member_ids.present?
	      return po_ids_by_org.length
			else
				return 0
			end
    end

    def po_ids_by_org
      return ActiveFedora::Base.where("id:(#{member_ids.join(' OR ')}) AND (has_model_ssim:BiologicalSpecimen OR has_model_ssim:CulturalHeritageObject)").map { |m| m.id }
    end

  end
end
