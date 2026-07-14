class UpdateCartItemReviewersJob < Hyrax::ApplicationJob
  include Morphosource::CartItems::RequestMessages

  queue_as Hyrax.config.update_fast_queue_name

  # media may be a Media work or a media id (resolved via its solr document)
  def perform(media=nil)
    # find all cart items with that media, then set the cart items' reviewers to the new reviewers
    media = SolrDocument.find(media) if media.is_a?(String)
    reviewers = Morphosource::DownloadReviewerResolverService.resolve_for_media(media)
    CartItem.where(work_id: media.id).each do |item|
      previous_reviewers = Array(item.reviewers)
      item.reviewers = reviewers
      item.save
      notify_new_reviewers(item, reviewers - previous_reviewers)
    end
  end

  private

  # Reviewers newly added to an outstanding request receive a download request
  # message; removed reviewers are not messaged.
  def notify_new_reviewers(item, new_reviewer_ids)
    return if new_reviewer_ids.empty? || !outstanding_request?(item)

    requestor = item.user
    return if requestor.blank?

    User.where(ms_id: new_reviewer_ids).each do |reviewer|
      message = "<p>#{user_email_link(requestor)} has requested to download the following media:</p>" +
        cart_item_message_content([item], "reviewer") +
        "<p>You have been added as a download reviewer for this media. Please review this request in your <a href='http://#{host_name}/dashboard/my/request_manager'>Manage Requests</a> dashboard.</p>" +
        "<p>Do Not Reply to this email. If you have questions for the user, please contact them at the email provided.</p>"
      deliver_message(email_sender, reviewer, message, "You have a download request to review")
    end
  end

  # A request awaiting review: requested and not yet approved, cleared,
  # canceled, denied, or expired
  def outstanding_request?(item)
    item.request_status == "Requested"
  end
end
