class MintWorkArkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # Mint ARK on an existing work that does not have an ARK yet
  #
  # @param work_id [String]
  def perform(work_id)
    if ActiveFedora::Base.exists?(work_id)
      work = ActiveFedora::Base.find(work_id)
      # check for work.class here?
      if work.ark.present?
        Rails.logger.error("ARK for #{work_id} exists already")
      else
        work.mint_ark
      end
    end
  end
end