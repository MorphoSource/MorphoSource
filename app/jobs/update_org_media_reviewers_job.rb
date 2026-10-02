# Refreshes cart_items.reviewers for every Media that names an OrganizationCollection as a
# reviewer, enqueuing one UpdateOrgMediaReviewersBatchJob per BATCH_SIZE Media.
class UpdateOrgMediaReviewersJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  BATCH_SIZE = 500

  # @param organization_id [String]
  def perform(organization_id)
    reindex_organization(organization_id)

    media_ids = ActiveFedora::SolrService.query('has_model_ssim:Media', fq: [reviewed_media_filter(organization_id)],
                                                fl: 'id', rows: 999999).map { |document| document['id'] }
    media_ids.each_slice(BATCH_SIZE) { |ids| UpdateOrgMediaReviewersBatchJob.perform_later(ids) }
  end

  private

  # The batch jobs resolve reviewers from the organization's Solr document, so it must be
  # current before they run. A deleted organization's Media are still refreshed.
  def reindex_organization(organization_id)
    OrganizationCollection.find(organization_id).update_index
  rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
    Rails.logger.info("[UpdateOrgMediaReviewersJob] organization #{organization_id} not found; not reindexed")
  end

  # The owner clause matches Media indexed before download_reviewer_mode_ssi existed, which
  # SolrDocument#download_reviewers resolves to their owner.
  def reviewed_media_filter(organization_id)
    token = Morphosource::SolrService.prepare_value(
      "#{Morphosource::MediaMetadata::ORG_COLLECTION_TOKEN_PREFIX}#{organization_id}"
    )
    owner = Morphosource::SolrService.prepare_value(organization_id)
    "download_reviewers_ssim:#{token} OR " \
      "(user_with_ownership_ssi:#{owner} AND -download_reviewer_mode_ssi:[* TO *])"
  end
end
