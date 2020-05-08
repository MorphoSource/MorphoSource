module MediaFinderHelper
  
  # this method recursively traverse the tree up to X level to gather all ids of child medias
  def child_media_ids(media, level, media_ids)
    if level == 0
      return []
    else
      child_medias = child_medias(media)
      child_medias.each do |child_media|
        media_ids << child_media.id
        level = level - 1
        media_ids << child_media_ids(child_media, level, media_ids)
      end
      media_ids.flatten.uniq # remove any duplicate IDs before returning
    end
  end

  # this method recursively traverse the tree up to X level to gather all ids of parent medias
  def parent_media_ids(media, level, media_ids)
    if level == 0
      return []
    else
      parent_medias = parent_medias(media)
      parent_medias.each do |parent_media|
        media_ids << parent_media.id
        level = level - 1
        media_ids << parent_media_ids(parent_media, level, media_ids)
      end
      media_ids.flatten.uniq # remove any duplicate IDs before returning
    end
  end

  # this method gets the top parent of a media
  # todo: will need to handle multiple parents later
  def top_parent_media_id_recurse(media)
    parent_medias = parent_medias(media)
    if parent_medias.empty?
      # no more parent (at the top level). return the id 
      return media.id
    else
      return top_parent_media_id_recurse(parent_medias.first)
    end
  end

  def top_parent_media_id(media)
    current_media_id = media.id
    return_id = top_parent_media_id_recurse(media)
    if return_id == current_media_id
      return nil
    else
      return_id
    end
  end

  # this method get siblings IDs from parents 1 level above
  def sibling_media_ids(media, media_ids)
    parent_medias = parent_medias(media)
    parent_medias.each do |parent_media|
      media_ids = child_media_ids(parent_media, 1, media_ids)
    end
    media_ids.flatten.uniq - [media.id] # remove any duplicate IDs, and remove the current media id before returning
  end

  # this method get a list of child media of a passed media 
  def child_medias(media)
    child_medias = []
    # Find child media: Media > ProcessingEvent > Media
    media.member_ids.each do |id|
      processing_event = nil
      child_media = nil
      if ProcessingEvent.where('id' => id).present? 
        processing_event = ProcessingEvent.where('id' => id).first
      end
      if processing_event.present?
        child_ids = processing_event.member_ids
        child_ids.each do |id|
          if Media.where('id' => id).present?
            child_media = Media.where('id' => id).first
            child_medias << child_media
          end
        end  # end child_ids.each
      end
    end # end media.member_ids.each
    child_medias
  end

  # this method get a list of parent media of a passed media 
  def parent_medias(media)
    parent_medias = []
    # Find parent media: Media < ProcessingEvent < Media    
    processing_events = ProcessingEvent.where('member_ids_ssim' => media.id)
    if processing_events.present?
      processing_events.each do |processing_event|
        medias = Media.where('member_ids_ssim' => processing_event.id)
        if medias.present?
          parent_medias += medias
        end
      end              
    end
    parent_medias
  end

end
