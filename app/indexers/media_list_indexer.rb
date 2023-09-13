class MediaListIndexer < Hyrax::CollectionWithBasicMetadataIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      # sorting
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