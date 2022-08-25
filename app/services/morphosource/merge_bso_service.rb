module Morphosource
  class MergeBsoService

    def self.call(merge_to=nil, merge_from=nil)

      bso_to = BiologicalSpecimen.find(merge_to)
      bso_from = BiologicalSpecimen.find(merge_from)
byebug


	  bso_from.media.each do |m|

        # detach media's IE, add IE under target bso, reindex media and related media
        ie = m.ImagingEvent
        ie.physical_object_id = [bso_to.id]

	  end

    end
  end
end
