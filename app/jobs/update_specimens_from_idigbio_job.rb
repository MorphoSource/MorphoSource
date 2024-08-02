class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(log_file)

    qry = "has_model_ssim:BiologicalSpecimen"
#    if @bso_id.present?
#      qry += " AND id:#{@bso_id}"
#    end
    result = ActiveFedora::SolrService.query(qry, rows: 999999)
    log.debug "#{result.count} specimens found"
    result.each do |hit|

      Morphosource::IDigBioUpdateService.call("000200003", true, false, false, nil)

      Morphosource::IDigBioUpdateService.call(hit.id, true, true, false, log_file)
#      UpdateBsoFromIdigbioJob.perform_later(hit.id, update, true, log_file)
    end

  end
end
