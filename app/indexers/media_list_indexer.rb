class MediaListIndexer < Hyrax::CollectionWithBasicMetadataIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      # sorting
      solr_doc['title_ssi'] = object.title&.first
      solr_doc['date_modified_dtsi'] = object.modified_date
      solr_doc['publication_status_si'] = publication_status
    end
  end

  def publication_status
    if object.visibility == 'restricted'
      'private'
    else
      object.visibility
    end
  end
end