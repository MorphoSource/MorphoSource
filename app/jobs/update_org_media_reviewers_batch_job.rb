class UpdateOrgMediaReviewersBatchJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # @param media_ids [Array<String>]
  def perform(media_ids)
    CartItem.refresh_reviewers(Morphosource::DownloadReviewerResolver.new.reviewers_by_media_id(media_ids))
  end
end
