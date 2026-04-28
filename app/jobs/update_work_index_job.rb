class UpdateWorkIndexJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(work_id)
    valkyrie_work = begin
      Hyrax.query_service.find_by(id: work_id)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      nil
    end

    # only use Valkyrie if work exists as resource, is persisted in postgres, and is not Hyrax::Work
    if valkyrie_work.present? && (valkyrie_work.model_name != "Hyrax::Work") && !valkyrie_work.wings?
      Hyrax.index_adapter.save(resource: valkyrie_work)
    elsif ::ActiveFedora::Base.exists?(work_id)
      ::ActiveFedora::Base.find(work_id).update_index
    end
  end
end
