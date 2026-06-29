class UpdateFileSetDataAllocationJob < Hyrax::ApplicationJob
  queue_as :default

  def perform(file_set)
    media = file_set.parent
    return unless media.is_a?(Media)

    data_allocation = media.active_fund_code_association&.fund_code&.data_allocation
    return unless data_allocation

    UpdateDataAllocationStorageJob.perform_later(data_allocation)
  end
end
