class SequentialSectionList < MediaList

  def self.collection_type
    Hyrax::CollectionType.find_by(machine_id: 'sequential_section_list')
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

  def human_readable_type
    "Sequential Section List"
  end

  # modality options for creating new media in the collection
  def media_modalities
    [["Sequential Section Scan", "SequentialSectionScan"]]
  end

end
