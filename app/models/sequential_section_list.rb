class SequentialSectionList < MediaList

  def collection_type
    Hyrax::CollectionType.find_by(machine_id: 'sequential_section_list')
  end

  def presenter_class
    Morphosource::Collections::MediaLists::SequentialSectionListPresenter
  end

  def human_readable_type
    "Sequential Section List"
  end

  # modality options for creating new media in the collection
  def media_modalities
    [["Sequential Section Scan", "SequentialSectionScan"]]
  end

end
