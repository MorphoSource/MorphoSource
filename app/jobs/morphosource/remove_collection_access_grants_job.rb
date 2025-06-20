module Morphosource
  class RemoveCollectionAccessGrantsJob < ApplicationJob
    queue_as Hyrax.config.update_slow_queue_name

    def perform(collection_id: nil, work_id: nil)
      return false if collection_id.blank? || work_id.blank?

      groups = ::Collection::DEFAULT_GROUP_ROLES.map{|r| "#{collection_id}_#{r}"}
      Array(work_id).each do |id|
        work = ActiveFedora::Base.find(id)
        work.edit_groups -= groups
        work.download_groups -= groups
        work.read_groups -= groups
        work.save!
        InheritPermissionsJob.perform_later(work) if work.is_a? Media
      end
    end
  end
end