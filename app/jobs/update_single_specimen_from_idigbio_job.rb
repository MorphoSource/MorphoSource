class UpdateSingleSpecimenFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(id, system_update=false, params_for_update)
byebug
    Morphosource::IDigBioUpdateService.call(id, true, system_update, params_for_update)
  end
end
