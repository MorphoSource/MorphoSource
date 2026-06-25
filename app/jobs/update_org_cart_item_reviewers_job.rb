class UpdateOrgCartItemReviewersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  def perform(org_id)
    org = OrganizationCollection.find(org_id)
    ids = affected_media_ids(org)
    return if ids.empty?

    reviewer_map = batch_reviewer_map(ids)
    ids.each do |media_id|
      pending_cart_items(media_id).each do |item|
        item.update(reviewers: reviewer_map[media_id])
      end
    end
  end

  private

  def affected_media_ids(org)
    escaped_id = RSolr.solr_escape(org.id)

    org_as_reviewer = ActiveFedora::SolrService.query(
      "has_model_ssim:Media AND download_reviewer_ssim:#{escaped_id}",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    org_as_owner_without_reviewer = ActiveFedora::SolrService.query(
      "has_model_ssim:Media AND user_with_ownership_ssi:#{escaped_id} AND -download_reviewer_ssim:[* TO *]",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    (org_as_reviewer + org_as_owner_without_reviewer).uniq
  end

  def batch_reviewer_map(media_ids)
    escaped_ids = media_ids.map { |id| RSolr.solr_escape(id) }.join(' OR ')
    results = ActiveFedora::SolrService.query(
      '*:*',
      fq: ["id:(#{escaped_ids})"],
      fl: ['id', 'download_reviewer_ssim'],
      rows: media_ids.size
    )
    results.each_with_object({}) do |doc, hash|
      hash[doc['id']] = doc['download_reviewer_ssim'] || []
    end
  end

  def pending_cart_items(work_id)
    CartItem.where(work_id: work_id)
            .where.not(date_requested: nil)
            .where(date_approved: nil, date_canceled: nil, date_denied: nil)
            .where("date_expired IS NULL OR date_expired >= ?", Date.current)
  end
end
