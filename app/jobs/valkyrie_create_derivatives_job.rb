# frozen_string_literal: true

# Overrides Hyrax's ValkyrieCreateDerivativesJob to support MorphoSource's
# broad range of file types (mesh, CT image series, archives, images, audio, video)
# via Morphosource::MsFileSetDerivativesService.
#
# Triggered by the 'file.characterized' event published by ValkyrieCharacterizationJob,
# which Hyrax's FileListener routes to this job class.
#
# @param file_set_id [String] ID of the Hyrax::FileSet Valkyrie resource
# @param file_id [String] ID of the Hyrax::FileMetadata Valkyrie resource
class ValkyrieCreateDerivativesJob < HeavyJob
  def perform(file_set_id, file_id, _filepath = nil)
    file_metadata = Hyrax.custom_queries.find_file_metadata_by(id: file_id)
    return if file_metadata.video? && !Hyrax.config.enable_ffmpeg

    file_set = Hyrax.query_service.find_by(id: file_set_id)
    file = Hyrax.storage_adapter.find_by(id: file_metadata.file_identifier)

    Morphosource::MsFileSetDerivativesService
      .new(file_set)
      .create_derivatives(file.disk_path)

    file_set.set_final_attributes

    Hyrax.index_adapter.save(resource: file_set)
    reindex_parent(file_set)
  end

  private

  def reindex_parent(file_set)
    parent = Hyrax.custom_queries.find_parent_work(resource: file_set)
    return unless parent&.thumbnail_id == file_set.id
    Hyrax.index_adapter.save(resource: parent)
  end
end
