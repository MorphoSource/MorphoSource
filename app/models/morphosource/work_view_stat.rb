module Morphosource
  class WorkViewStat < ::WorkViewStat
    def self.filter(work)
      if work.is_a? String
        # Assume string is work ID
        { work_id: work }
      else
        { work_id: work.id }
      end
    end

    def self.polymorphic_path(object)
      if object.is_a? String
        "/concern/media/#{object}"
      else
        super(object)
      end
    end
  end
end