class UpdateCartItemReviewersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  def perform(media_id)
    begin
      media = Media.find(media_id)
    rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
      return
    end

    reviewers = Morphosource::DownloadReviewerResolver.new.call(media)
    CartItem.where(work_id: media_id).find_each do |item|
      next if Array(item.reviewers).to_set == reviewers.to_set

      # Deleted requestors leave CartItems whose required User association no longer validates.
      item.update_columns(reviewers: reviewers, updated_at: Time.current)
    end
  end
end
