class SequentialSectionList < MediaList

  def self.collection_type
    Hyrax::CollectionType.find_by(machine_id: 'sequential_section_list')
  end

  def human_readable_type
    "Sequential Section List"
  end

end
