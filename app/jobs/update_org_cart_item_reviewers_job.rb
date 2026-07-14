class UpdateOrgCartItemReviewersJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  # Refreshes cart item reviewers for all media whose effective reviewers depend
  # on the given organization: media listing the org (or an ancestor org that
  # resolves through it) as download_reviewer, and media owned by such an org.
  # The per-media resolution happens in UpdateCartItemReviewersJob.
  def perform(org_id)
    org = OrganizationCollection.find(org_id)
    affected_media_ids(org).each do |media_id|
      UpdateCartItemReviewersJob.perform_later(media_id)
    end
  end

  private

  def affected_media_ids(org)
    ([org.id] + ancestor_org_ids(org.id)).uniq.flat_map do |oid|
      escaped_reviewer_value = RSolr.solr_escape(Morphosource::DownloadReviewerResolverService.org_value(oid))
      escaped = RSolr.solr_escape(oid)

      org_as_reviewer = ActiveFedora::SolrService.query(
        "has_model_ssim:Media AND download_reviewer_ssim:#{escaped_reviewer_value}",
        fl: ['id'], rows: 999999
      ).map { |r| r['id'] }

      org_as_owner = ActiveFedora::SolrService.query(
        "has_model_ssim:Media AND user_with_ownership_ssi:#{escaped}",
        fl: ['id'], rows: 999999
      ).map { |r| r['id'] }

      org_as_reviewer + org_as_owner
    end.uniq
  end

  def ancestor_org_ids(org_id, visited = Set.new)
    return [] if visited.include?(org_id)
    visited << org_id

    escaped_reviewer_value = RSolr.solr_escape(Morphosource::DownloadReviewerResolverService.org_value(org_id))
    parent_ids = ActiveFedora::SolrService.query(
      "has_model_ssim:OrganizationCollection AND download_reviewer_ssim:#{escaped_reviewer_value}",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    parent_ids + parent_ids.flat_map { |pid| ancestor_org_ids(pid, visited) }
  end
end
