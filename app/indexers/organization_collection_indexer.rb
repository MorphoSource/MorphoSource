class OrganizationCollectionIndexer < Hyrax::CollectionWithBasicMetadataIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['media_ownership_transfer_bsi'] = object.media_ownership_transfer
      solr_doc['generic_type_sim'] = ['Collection']
      solr_doc['title_ssi'] = object.title.first
      solr_doc['date_modified_dtsi'] = object.modified_date if object.modified_date.present?
      solr_doc['display_name_ssi'] = object.display_name
      solr_doc['ark_tesim'] = object.ark
      solr_doc['ark_ssim'] = object.ark
    end
  end
end