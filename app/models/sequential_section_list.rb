class SequentialSectionList < MediaList

  def collection_type
    Hyrax::CollectionType.find_by(machine_id: 'sequential_section_list')
  end

  def presenter_class
    Morphosource::Collections::MediaLists::SequentialSectionListPresenter
  end

end
