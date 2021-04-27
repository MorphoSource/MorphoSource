class UpdateCartItemReviewersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.reindex_queue_name

  def perform(media=nil)
    # find all cart items with that media, then set the cart items' reviewers to the new reviewers
    cart_items = CartItem.where(work_id: media.id)
    cart_items.each do |item|
      item.reviewers = media.reviewer
      item.save!
    end
  end
end