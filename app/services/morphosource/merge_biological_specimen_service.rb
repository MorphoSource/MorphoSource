module Morphosource
  class MergeBiologicalSpecimenService

    def self.call(merge_to=nil, merge_from=nil, delete_dup=true, report_only=false)
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
      	ie.save unless report_only
		  end
		  if media_list.present?
				UpdateWorkIndexJob.perform_later(merge_to)
		  end
		  if delete_dup && !report_only
		  	bso_from.destroy 
		  	puts " specimen #{merge_from} destroyed"
		  end
		  return media_list, ie_list
    end

  end
end
