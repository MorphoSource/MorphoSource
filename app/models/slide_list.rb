class SlideList < MediaList

  def collection_type
    Hyrax::CollectionType.find_by(machine_id: 'slide_list')
  end
  
end
