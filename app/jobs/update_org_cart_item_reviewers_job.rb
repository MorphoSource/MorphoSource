class UpdateOrgCartItemReviewersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  # Refreshes cart item reviewers for all media whose effective reviewers depend
  # on the given organization: media listing the org as download_reviewer, and
  # media owned by the org (whose blank reviewer field falls back to the owner).
  # The per-media resolution happens in UpdateCartItemReviewersJob.
  def perform(org_id)
    org = OrganizationCollection.find(org_id)
    media_ids_with_cart_items(org).each do |media_id|
      UpdateCartItemReviewersJob.perform_later(media_id)
    end
  end

  private

  # Most affected media have no cart items to refresh, so only fan out
  # per-media jobs for the ones that do
  def media_ids_with_cart_items(org)
    affected_media_ids(org).each_slice(1000).flat_map do |batch|
      CartItem.where(work_id: batch).distinct.pluck(:work_id)
    end
  end

  def affected_media_ids(org)
    escaped_reviewer_value = RSolr.solr_escape(Morphosource::DownloadReviewerResolverService.org_value(org.id))
    escaped = RSolr.solr_escape(org.id)

    org_as_reviewer = ActiveFedora::SolrService.query(
      "has_model_ssim:Media AND download_reviewer_ssim:#{escaped_reviewer_value}",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    org_as_owner = ActiveFedora::SolrService.query(
      "has_model_ssim:Media AND user_with_ownership_ssi:#{escaped}",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    (org_as_reviewer + org_as_owner).uniq
  end
end
