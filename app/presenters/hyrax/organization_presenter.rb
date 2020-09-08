# Generated via
#  `rails generate hyrax:work Organization`
module Hyrax
  class OrganizationPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :organization_type, :institution_name, :institution_code, :collection_code, :recordset_id, :address, :city, :state_province, :country, :contact_person, :team_id, :member_ids, to: :solr_document


    def total_media
#      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id} AND has_model_ssim:Media").count
    end

    def total_po
#      ActiveFedora::Base.where("member_of_collection_ids_ssim:#{id} AND has_model_ssim:Media AND -physical_object_id_tesim:nil").count
			if member_ids.present?
				member_ids.length
#				member_ids.each do |id|
#					work = Works.find(id)
#byebug
#				end
#	      ActiveFedora::Base.where("id:(#{member_ids.join(',')}) ").count
			else
				0
			end
    end

  end
end
