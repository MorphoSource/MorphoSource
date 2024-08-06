class UpdateSingleSpecimenFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_slow_queue_name

  def perform(id, system_update=false, log_file, canonical_taxonomy_id, taxonomy_id_array, taxonomy_params_array, biospec_model_params)
    Morphosource::IDigBioUpdateService.call(id, true, system_update, log_file, canonical_taxonomy_id, taxonomy_id_array, taxonomy_params_array, biospec_model_params)
  end
end
