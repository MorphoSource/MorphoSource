class MintWorkArkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # Mint ARK on an existing work that does not have an ARK yet
  #
  # @param work_id [String]
  def perform(work_id)
    resource = find_resource(work_id)
    resource.is_a?(Valkyrie::Resource) ? mint_resource_ark(resource) : mint_active_fedora_ark(work_id)
  end

  private

  def find_resource(work_id)
    Hyrax.query_service.find_by(id: work_id)
  rescue Valkyrie::Persistence::ObjectNotFoundError
    nil
  end

  def mint_resource_ark(resource)
    return Rails.logger.error("ARK for #{resource.id.to_s} exists already") if resource.ark.present?

    resource.mint_ark
    saved = Hyrax.persister.save(resource: resource)
    Hyrax.index_adapter.save(resource: saved)
  end

  def mint_active_fedora_ark(work_id)
    return unless ActiveFedora::Base.exists?(work_id)

    work = ActiveFedora::Base.find(work_id)
    return Rails.logger.error("ARK for #{work_id} exists already") if work.ark.present?

    work.mint_ark
    work.save
    work.update_index
  end
end
