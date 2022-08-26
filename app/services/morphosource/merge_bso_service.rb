module Morphosource
  class MergeBsoService

    def self.call(merge_to=nil, merge_from=nil)
      bso_to = BiologicalSpecimen.find(merge_to)
      bso_from = BiologicalSpecimen.find(merge_from)
	  ie_list = []
	  media_list = []
	  bso_from.media.each do |m|
        # detach media's IE, add IE under target bso, reindex media and related media
        media_list << m.id
        ie = m.imaging_event
        ie_list << ie.id
		#puts "moving IE #{ie.id} from bso #{ie.physical_object_id&.first} to bso #{bso_to.id}"
        ie.physical_object_id = [bso_to.id]
        ie.save
	  end
	  puts "moved media #{media_list}, IE #{ie_list} from bso #{bso_from.id} to bso #{bso_to.id}"
	  return nil
    end

  end
end
