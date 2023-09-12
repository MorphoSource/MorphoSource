class UpdateOrganizationTransferRequestsJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  def perform(transfer_requests=nil, new_manager)
    transfer_requests.each do |req|
      if Media.exists?(req.work_id)
        media = Media.find(req.work_id)
        media.create_new_organization_transfer_request(new_manager, true)
      end
    end
  end
end