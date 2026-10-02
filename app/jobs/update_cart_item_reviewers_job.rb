class UpdateCartItemReviewersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  # @param media_id [String]
  def perform(media_id)
    begin
      media = Media.find(media_id)
    rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
      return
    end

    CartItem.refresh_reviewers(media_id => Morphosource::DownloadReviewerResolver.new.call(media))
  end
end
