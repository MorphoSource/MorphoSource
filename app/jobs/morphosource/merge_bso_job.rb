module Morphosource
  class MergeBsoJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_slow_queue_name

    def perform(merge_to=nil, merge_from=[])
      return false if merge_to.nil? || !merge_from.present?

      
    end


  end
end
