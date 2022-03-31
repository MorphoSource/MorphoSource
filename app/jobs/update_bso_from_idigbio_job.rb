class UpdateBsoFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(o, save_work=false)
	Rails.logger.info "UpdateBsoFromIdigbio: Updating BiologicalSpecimen #{o.id}"
	o.update_metadata_from_idigbio_occurrence_id
	o.save if save_work
  end
end
