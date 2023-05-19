class PrepareCreateDerivativesJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(work_id)
    work = ActiveFedora::Base.find(work_id)
    if work.class == Media
      if work.file_sets.first.present?
        work = work.file_sets.first
      else
        raise "No FileSet present for provided Media work"
      end
    elsif work.class != FileSet
      raise 'Invalid work type'
    end

    wrapper = JobIoWrapper.find_by(file_set_id: work.id)
    path_hint = wrapper.uploaded_file ? wrapper.uploaded_file.uploader.path : wrapper.path

    if work.is_remote_backed?
      if path_hint && File.exist?(path_hint)      
        CreateDerivativesJob.perform_later(work, work.original_file.id, path_hint)
      else
        user = User.find_by_user_key(work.depositor)
        operation =  Hyrax::Operation.create!(user: user, operation_type: "Attach Remote File")
        ImportUrlJob.perform_later(work, operation, {})
        # CharacterizeJob & CreateDerivativesJob will be called later in file_actor after ImportUrlJob
      end
    else
      CreateDerivativesJob.perform_later(work, work.original_file.id, path_hint)
    end
  end
end