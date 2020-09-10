module Hyrax::Browse::BrowseOrganizationsHelper

    delegate :organization_type, to: :solr_document

    def total_scanning_facilities
      return ActiveFedora::Base.where(" has_model_ssim:Organization AND #{Solrizer.solr_name('organization_type', :stored_searchable)}:\"Scanning Facility\"").count
    end

    def total_collection_and_scanning_facilities
      return ActiveFedora::Base.where(" has_model_ssim:Organization AND #{Solrizer.solr_name('organization_type', :stored_searchable)}:\"Collection and Scanning Facility\"").count
    end

end
