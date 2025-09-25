class UpdateWorkIndexJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(work_id)
    if (work = Hyrax.query_service.find_by(id: work_id)).present?
      Hyrax.index_adapter.save(resource: work)
    elsif ::ActiveFedora::Base.exists?(work_id)
      ::ActiveFedora::Base.find(work_id).update_index
    end
  end
end
