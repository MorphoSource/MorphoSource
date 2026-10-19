class UpdateOrgMediaReviewersBatchJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  FIELDS = %w[id has_model_ssim download_reviewers_ssim download_reviewer_mode_ssi user_with_ownership_ssi].freeze

  # @param media_ids [Array<String>]
  def perform(media_ids)
    resolver = Morphosource::DownloadReviewerResolver.new
    documents = ActiveFedora::SolrService.query('has_model_ssim:Media', fq: ["{!terms f=id}#{media_ids.join(',')}"],
                                                fl: FIELDS.join(','), rows: media_ids.size, method: :post)

    CartItem.refresh_reviewers(documents.to_h { |document| [document['id'], resolver.call(SolrDocument.new(document.to_h))] })
  end
end
