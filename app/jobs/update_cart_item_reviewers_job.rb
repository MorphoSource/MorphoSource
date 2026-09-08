class UpdateCartItemReviewersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  def perform(media_id)
    reviewers = Morphosource::DownloadReviewerResolver.new.call(Media.find(media_id))
    CartItem.where(work_id: media_id).find_each do |item|
      next if Array(item.reviewers).to_set == reviewers.to_set

      item.update!(reviewers: reviewers)
    end
  end
end
