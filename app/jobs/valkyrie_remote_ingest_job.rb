# Kicks off the appropriate ingest job for a Valkyrie FileSet created from a
# remote URL. Mirrors the branching logic in
# CreateWithRemoteFilesActor::IngestRemoteFilesService#__create_file_from_url.
class ValkyrieRemoteIngestJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [Hyrax::FileSet] file_set - the persisted Valkyrie FileSet to ingest
  # @param [Hash] file_info - { url:, file_name:, auth_header:, mime_type_of_remote: }
  def perform(file_set, file_info)
    uri = URI.parse(Addressable::URI.escape(file_info[:url]))

    unless validate_remote_url(uri)
      Rails.logger.error "ValkyrieRemoteIngestJob: invalid remote url #{file_info[:url]}"
      return
    end

    auth_header = file_info.fetch(:auth_header, {})
    user = User.find_by_user_key(file_set.depositor)

    # todovalk: decide if it is actually best to use these import jobs still, or something more unified, or how these flow to Valkyrie? compare to ValkyrieIngestJob and actor flows
    if uri.scheme == 'file'
      # Turn any %20 into spaces.
      # Turn + signs to %2B first, otherwise unescape will convert + signs to spaces.
      file_path = CGI.unescape(uri.path.gsub('+', '%2B'))
      IngestLocalFileJob.perform_later(file_set, file_path, user)
    elsif file_set.has_remote_manifest?
      operation = Hyrax::Operation.create!(user: user, operation_type: "Attach Remote File")
      ImportUrlJob.perform_now(file_set, operation, auth_header)
    else
      operation = Hyrax::Operation.create!(user: user, operation_type: "Attach Remote File")
      ImportUrlJob.perform_later(file_set, operation, auth_header)
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
end
