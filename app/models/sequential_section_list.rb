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

end
