class OrganizationCollectionIndexer < Hyrax::CollectionWithBasicMetadataIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['media_ownership_transfer_bsi'] = object.media_ownership_transfer
      solr_doc['generic_type_sim'] = ['Collection']
      solr_doc['title_ssi'] = object.title.first
    end
  end
end