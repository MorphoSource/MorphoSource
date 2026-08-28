class OrganizationCollectionIndexer < Hyrax::CollectionWithBasicMetadataIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['media_ownership_transfer_bsi'] = object.media_ownership_transfer
      solr_doc['reviews_object_media_downloads_bsi'] = object.reviews_object_media_downloads
      solr_doc['managers_are_download_reviewers_bsi'] = object.managers_are_download_reviewers
      solr_doc['custom_download_reviewer_users_ssim'] = object.custom_download_reviewer_users
      solr_doc['generic_type_sim'] = ['Collection']
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_modified_dtsi'] = object.modified_date
      solr_doc['display_name_ssi'] = object.display_name
      solr_doc['ark_tesim'] = object.ark
      solr_doc['ark_ssim'] = object.ark
      solr_doc['date_managed_dtsi'] = object.date_managed
      solr_doc['continent_ssim'] = object.continent # some countries have multiple continents
    end
  end
end