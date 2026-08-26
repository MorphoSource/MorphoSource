class PrepareCreateDerivativesJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(work_id)
    file_set = resolve_file_set(work_id)

    if file_set.is_a?(::Valkyrie::Resource)
      return if file_set.has_remote_manifest?
      file_metadata = Hyrax.custom_queries.find_original_file(file_set: file_set)
      ValkyrieCreateDerivativesJob.perform_later(file_set.id.to_s, file_metadata.id.to_s)
    else
      wrapper = JobIoWrapper.find_by(file_set_id: file_set.id)
      path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path

      if file_set.is_remote_backed?
        if path_hint && File.exist?(path_hint)
          CreateDerivativesJob.perform_later(file_set, file_set.original_file.id, path_hint)
        else
          user = User.find_by_user_key(file_set.depositor)
          operation = Hyrax::Operation.create!(user: user, operation_type: "Attach Remote File")
          ImportUrlJob.perform_later(file_set, operation, {})
          # CharacterizeJob & CreateDerivativesJob will be called later in file_actor after ImportUrlJob
        end
      else
        CreateDerivativesJob.perform_later(file_set, file_set.original_file.id, path_hint)
      end
    end
  end

  private

  def resolve_file_set(work_id)
    work = ActiveFedora::Base.find(work_id)
    if work.class == Media
      fs = work.file_sets.first
      raise "No FileSet present for provided Media work" unless fs.present?
      fs
    elsif work.respond_to?(:file_set?) && work.file_set?
      work
    else
      raise 'Invalid work type'
    end
  rescue ActiveFedora::ObjectNotFoundError
    Hyrax.query_service.find_by(id: Valkyrie::ID.new(work_id))
  end
end
