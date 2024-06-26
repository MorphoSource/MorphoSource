class SequentialSectionList < MediaList

  self.indexer = SequentialSectionListIndexer

  def self.collection_type
    Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
  end

  def collection_type
    self.class.collection_type
  end

  def human_readable_type
    "Sequential Section List"
  end

  def presenter_class
    Morphosource::Collections::MediaLists::SequentialSectionListPresenter
  end

  def search_builder_class
    Morphosource::Users::EditMedia::EditSequentialSectionScansSearchBuilder
  end

  def specimen
    specimen_doc.present? ? BiologicalSpecimen.find(specimen_doc['id']) : nil
  end

  def specimen_doc
    return if media_docs.empty?

    id = media_docs.first['physical_object_id_ssim']&.first
    id.present? ? SolrDocument.find(id) : nil
  end

  def human_readable_type
    "Sequential Section List"
  end

  # modality options for creating new media in the collection
  def media_modalities
    [["Sequential Section Scan", "SequentialSectionScan"]]
  end

  def sequential_section_list?
    true
  end

end
