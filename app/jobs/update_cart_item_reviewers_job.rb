class UpdateCartItemReviewersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  # media may be a Media work or a media id (resolved via its solr document)
  def perform(media=nil)
    # find all cart items with that media, then set the cart items' reviewers to the new reviewers
    media = SolrDocument.find(media) if media.is_a?(String)
    reviewers = Morphosource::DownloadReviewerResolverService.resolve_for_media(media)
    CartItem.where(work_id: media.id).each do |item|
      item.reviewers = reviewers
      item.save
    end
  end
end