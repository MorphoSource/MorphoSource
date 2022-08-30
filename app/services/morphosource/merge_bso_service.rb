module Morphosource
  class MergeBsoService

    def self.call(merge_to=nil, merge_from=nil, delete_dup=true)
      bso_to = BiologicalSpecimen.find(merge_to)
      bso_from = BiologicalSpecimen.find(merge_from)
		  ie_list = []
		  media_list = []
		  bso_from.media.each do |m|
        # detach media's IE, add IE under target bso, reindex bso (reindex media and related media should be triggered after)
        media_list << m.id
        ie = m.imaging_event
        ie_list << ie.id
        ie.physical_object_id = [bso_to.id]

# might have to send ie.save to a job??

#        ie.save
		  end
		  if media_list.present?
				UpdateWorkIndexJob.perform_later(merge_to)
				puts "moved media #{media_list}, IE #{ie_list} from specimen #{merge_from} to specimen #{merge_to}"
			else
        puts "no media found"		  
		  end
		  if delete_dup
		  	bso_from.destroy 
		  	puts "specimen #{bso_from} destroyed"
		  end
	  return nil
    end

  end
end
