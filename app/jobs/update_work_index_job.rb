class UpdateWorkIndexJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(work_id)
    if ::ActiveFedora::Base.exists?(work_id)
      ::ActiveFedora::Base.find(work_id).update_index
    end
  end
end
