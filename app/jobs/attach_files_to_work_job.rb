# Converts UploadedFiles into FileSets and attaches them to works.
# When Hyrax.config.use_valkyrie? is true, delegates to
# Morphosource::WorkUploadsHandler which creates Valkyrie FileSets and attaches
# them to the AF work via valkyrie_member_ids. Otherwise falls back to the
# standard Hyrax AF path using FileSetActor.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    if Hyrax.config.use_valkyrie?
      Morphosource::WorkUploadsHandler.new(work: work, work_attributes: work_attributes)
        .add(files: uploaded_files)
        .attach
    else
      perform_af(work, uploaded_files, work_attributes)
    end
  end

  private

  def perform_af(work, uploaded_files, work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    uploaded_files.each do |uploaded_file|
      next if uploaded_file.file_set_uri.present?
      attach_work(user, work, work_attributes, work_permissions, uploaded_file)
    end
  end

  def attach_work(user, work, work_attributes, work_permissions, uploaded_file)
    actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user, work.is_remote_backed?)
    uploaded_file.add_file_set!(actor.file_set)
    actor.file_set.permissions_attributes = work_permissions
    actor.create_metadata(metadata)
    actor.create_content(uploaded_file)
    actor.attach_to_work(work)
  end
  # The attributes used for visibility - sent as initial params to created FileSets.
  def visibility_attributes(attributes)
    attributes.slice(:visibility, :visibility_during_lease,
                     :visibility_after_lease, :lease_expiration_date,
                     :embargo_release_date, :visibility_during_embargo,
                     :visibility_after_embargo)
  end

  def validate_files!(uploaded_files)
    uploaded_files.each do |uploaded_file|
      next if uploaded_file.is_a? Hyrax::UploadedFile
      raise ArgumentError, "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
    end
  end

  ##
  # A work with files attached by a proxy user will set the depositor as the intended user
  # that the proxy was depositing on behalf of. See tickets #2764, #2902.
  def proxy_or_depositor(work)
    work.on_behalf_of.presence || work.depositor
  end
end
