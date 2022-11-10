class CreateDerivativesJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.heavy_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    return if file_set.video? && !Hyrax.config.enable_ffmpeg
    filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)

    file_set.create_derivatives(filename)

    # Since file characterization and derivative creation overwrites the mime_type set by 
    # calling AddExternalFileToFileSet, this needs to be called here to update the mime_type 
    file_set.set_mime_type_if_remote

    # Reload from Fedora and reindex for thumbnail and extracted text
    file_set.reload
    file_set.update_index
    file_set.parent.update_index if parent_needs_reindex?(file_set)
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent
    file_set.parent.thumbnail_id == file_set.id
  end
end