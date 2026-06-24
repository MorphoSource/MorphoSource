class UpdateOrgCartItemReviewersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  def perform(org_id)
    org = OrganizationCollection.find(org_id)

    affected_media_ids(org).each do |media_id|
      media_doc = SolrDocument.find(media_id)
      pending_cart_items(media_id).each do |item|
        item.update(reviewers: media_doc.reviewer)
      end
    end
  end

  private

  def affected_media_ids(org)
    org_as_reviewer = ActiveFedora::SolrService.query(
      "has_model_ssim:Media AND download_reviewer_ssim:#{org.id}",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    org_as_owner_without_reviewer = ActiveFedora::SolrService.query(
      "has_model_ssim:Media AND user_with_ownership_ssi:#{org.id} AND -download_reviewer_ssim:[* TO *]",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    (org_as_reviewer + org_as_owner_without_reviewer).uniq
  end

  def pending_cart_items(work_id)
    CartItem.where(work_id: work_id)
            .where.not(date_requested: nil)
            .where(date_approved: nil, date_canceled: nil, date_denied: nil)
            .where("date_expired IS NULL OR date_expired >= ?", Date.today)
  end
end
