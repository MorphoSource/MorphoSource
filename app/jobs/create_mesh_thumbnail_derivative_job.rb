class CreateMeshThumbnailDerivativeJob < HeavyJob
  # @param [String] file_set_id identifier for FileSet
  def perform(file_set_id)
    file_set = FileSet.find(file_set_id)
    return if !file_set.mesh?

    glb_path = Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'glb')
    if glb_path.present? && File.exists?(glb_path) && File.size(glb_path) > 0
      Morphosource::Derivatives::MeshThumbnailDerivatives.create(
        glb_path,
        outputs: [ {
          label: :thumbnail,
          url: Morphosource::MsFileSetDerivativesService.new(file_set).derivative_url('thumbnail')
        } ]
      ) 
    end

    file_set.set_final_attributes

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