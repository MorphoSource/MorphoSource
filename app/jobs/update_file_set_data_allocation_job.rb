class UpdateFileSetDataAllocationJob < Hyrax::ApplicationJob
  queue_as :default

  def perform(file_set)
    media = file_set.parent
    return unless media.is_a?(Media)

    fcma = FundCodeMediaAssociation.where(media: media.id, active: true).first
    return unless fcma

    data_allocation = fcma.fund_code.data_allocation
    return unless data_allocation

    UpdateDataAllocationStorageJob.perform_later(data_allocation)
  end
end
