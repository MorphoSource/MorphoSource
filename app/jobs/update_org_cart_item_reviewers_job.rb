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
    ([org.id] + ancestor_org_ids(org.id)).uniq.flat_map do |oid|
      escaped = RSolr.solr_escape(oid)

      org_as_reviewer = ActiveFedora::SolrService.query(
        "has_model_ssim:Media AND download_reviewer_ssim:#{escaped}",
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

    escaped = RSolr.solr_escape(org_id)
    parent_ids = ActiveFedora::SolrService.query(
      "has_model_ssim:OrganizationCollection AND download_reviewer_ssim:#{escaped}",
      fl: ['id'], rows: 999999
    ).map { |r| r['id'] }

    parent_ids + parent_ids.flat_map { |pid| ancestor_org_ids(pid, visited) }
  end

  SOLR_BATCH_SIZE = 100

  def batch_reviewer_map(media_ids)
    results = media_ids.each_slice(SOLR_BATCH_SIZE).flat_map do |batch|
      escaped_ids = batch.map { |id| RSolr.solr_escape(id) }.join(' OR ')
      ActiveFedora::SolrService.query(
        '*:*',
        fq: ["id:(#{escaped_ids})"],
        fl: ['id', 'download_reviewer_ssim', 'user_with_ownership_ssi'],
        rows: batch.size
      )
    end

    all_ids = results.flat_map { |doc|
      Array(doc['download_reviewer_ssim']) + Array(doc['user_with_ownership_ssi'])
    }.uniq

    user_ms_ids  = User.where(ms_id: all_ids).map(&:ms_id).to_set
    org_reviewer_map = OrganizationCollection.where(id: all_ids)
                                             .each_with_object({}) { |org, h| h[org.id] = org.media_download_reviewers }

    results.each_with_object({}) do |doc, hash|
      hash[doc['id']] = resolve_reviewers(
        Array(doc['download_reviewer_ssim']),
        doc['user_with_ownership_ssi'],
        user_ms_ids,
        org_reviewer_map
      )
    end
  end

  def resolve_reviewers(download_reviewer, ownership, user_ms_ids, org_reviewer_map)
    if download_reviewer.present?
      user_ids = download_reviewer.select { |id| user_ms_ids.include?(id) }
      org_ids  = download_reviewer.flat_map { |id| org_reviewer_map[id] || [] }
      resolved = (user_ids + org_ids).uniq
      return resolved if resolved.present?
    end

    org_reviewer_map[ownership] || Array(ownership)
  end

  def pending_cart_items(work_id)
    CartItem.where(work_id: work_id)
            .where.not(date_requested: nil)
            .where(date_approved: nil, date_canceled: nil, date_denied: nil)
            .where("date_expired IS NULL OR date_expired >= ?", Date.current)
  end
end
