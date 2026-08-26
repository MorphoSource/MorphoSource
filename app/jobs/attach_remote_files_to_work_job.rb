# Converts remote file info hashes into FileSets and attaches them to works.
# When Hyrax.config.use_valkyrie? is true, delegates to
# Morphosource::WorkUploadsHandler which creates Valkyrie FileSets and attaches
# them to the AF work via valkyrie_member_ids. Otherwise falls back to the
# standard Hyrax AF path using FileSetActor.
class AttachRemoteFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hash>] remote_files - array of { url:, file_name:, mime_type_of_remote:, auth_header: } hashes
  def perform(work, remote_files)
    return if remote_files.blank?
    valid_files = validate_remote_files!(remote_files)
    return if valid_files.empty?

    if Hyrax.config.use_valkyrie?
      Morphosource::WorkUploadsHandler.new(work: work, user: proxy_or_depositor(work))
        .add_remote_files(remote_files: valid_files)
        .attach
    else
      perform_af(work, valid_files)
    end
  end

  private

  def validate_remote_files!(remote_files)
    remote_files.each_with_object([]) do |file_info, arr|
      next if file_info.blank? || file_info[:url].blank?
      uri = URI.parse(Addressable::URI.escape(file_info[:url]))
      unless validate_remote_url(uri)
        raise ArgumentError, "User attempted to ingest file from url #{file_info[:url]}, which doesn't pass validation"
      end
      arr << file_info
    end
  end

  # @param uri [URI] the uri of the resource to import
  def validate_remote_url(uri)
    if uri.scheme == 'file'
      path = File.absolute_path(CGI.unescape(uri.path))
      Hyrax.config.whitelisted_ingest_dirs.any? do |dir|
        path.start_with?(dir) && path.length > dir.length
      end
    else
      Rails.logger.debug "Assuming #{uri.scheme} uri is valid without a serious attempt to validate: #{uri}"
      true
    end
  end

  def perform_af(work, valid_files)
    user = proxy_or_depositor(work)
    valid_files.each do |file_info|
      uri = URI.parse(Addressable::URI.escape(file_info[:url]))
      create_file_from_url(work, user, uri, file_info[:file_name],
                           file_info.fetch(:auth_header, {}),
                           file_info[:mime_type_of_remote])
    end
  end

  def create_file_from_url(work, user, uri, file_name, auth_header, mime_type_of_remote = nil)
    import_url = URI.decode_www_form_component(uri.to_s)
    use_valkyrie = false
    case work
    when Valkyrie::Resource
      file_set = Hyrax.persister.save(resource: Hyrax::FileSet.new(import_url: import_url, label: file_name))
      use_valkyrie = true
    else
      file_set = ::FileSet.new(import_url: import_url, label: file_name, mime_type_of_remote: mime_type_of_remote)
    end
    actor = Hyrax::Actors::FileSetActor.new(file_set, user, use_valkyrie)
    actor.create_metadata(visibility: work.visibility)
    actor.attach_to_work(work)
    file_set.save! if file_set.respond_to?(:save!)
    if uri.scheme == 'file'
      IngestLocalFileJob.perform_later(file_set, CGI.unescape(uri.path.gsub('+', '%2B')), user)
    elsif work.has_remote_manifest?
      ImportUrlJob.perform_now(file_set, operation_for(user: user), auth_header)
    else
      ImportUrlJob.perform_later(file_set, operation_for(user: user), auth_header)
    end
  end

  def operation_for(user:)
    Hyrax::Operation.create!(user: user, operation_type: "Attach Remote File")
  end

  ##
  # A work with files attached by a proxy user will set the depositor as the intended user
  # that the proxy was depositing on behalf of. See tickets #2764, #2902.
  def proxy_or_depositor(work)
    User.find_by_user_key(work.on_behalf_of.presence || work.depositor)
  end
end
