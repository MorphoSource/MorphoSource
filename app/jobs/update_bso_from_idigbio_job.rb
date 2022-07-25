class UpdateBsoFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(o, save_work=false, system_update=false)
	Rails.logger.debug "UpdateBsoFromIdigbio: Updating BiologicalSpecimen #{o.id}"
	o.update_metadata_from_idigbio_occurrence_id(false, system_update)
	o.save if save_work
  end
end
