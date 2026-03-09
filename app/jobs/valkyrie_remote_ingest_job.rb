require 'browse_everything/retriever'

# Ingests a remote file into a Valkyrie FileSet.
# Consolidates the Valkyrie-specific logic previously delegated to
# IngestLocalFileJob and ImportUrlJob.
# Remote files may include one of the following scenarios
#   1. Local file from secondary source that must be ingested locally (BrowseEverything Globus file)
#   2. URL reference to file that must be downloaded and ingested locally (BrowseEverything URL)
#   3. URL reference to file with no local ingest but temporary file copy download (Remote backed media)
#   4. URL reference to file with no local ingest and no temporary copy (Remote backed remote manifest media)
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

    @file_set = file_set
    @user = User.find_by_user_key(@file_set.depositor)
    auth_header = file_info.fetch(:auth_header, {})

    if uri.scheme == 'file'
      # Remote file scenario 1
      ingest_local_file(uri)
    else
      # Remote file scenarios 2 - 4
      ingest_remote_url(uri, auth_header)
    end
  end

  private

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

  # Handles file:// URIs. Inlined from IngestLocalFileJob (Valkyrie path).
  def ingest_local_file(uri)
    # Turn any %20 into spaces.
    # Turn + signs to %2B first, otherwise unescape will convert + signs to spaces.
    file_path = CGI.unescape(uri.path.gsub('+', '%2B'))
    if @file_set.label.blank?
      @file_set.label = File.basename(file_path)
      @file_set = Hyrax.persister.save(resource: @file_set)
    end
    Hyrax::ValkyrieUpload.file(
      io: File.open(file_path),
      filename: @file_set.label,
      file_set: @file_set,
      use: Hyrax::FileMetadata::Use::ORIGINAL_FILE,
      user: @user
    )
    Hyrax.config.callback.run(:after_import_local_file_success, @file_set, @user, file_path, warn: false)
  rescue SystemCallError
    Hyrax.config.callback.run(:after_import_local_file_failure, @file_set, @user, file_path, warn: false)
  end

  # Handles http(s):// URIs. Inlined from ImportUrlJob (Valkyrie path).
  def ingest_remote_url(uri, auth_header)
    @operation = Hyrax::Operation.create!(user: @user, operation_type: "Attach Remote File")
    @operation.performing!


    if @file_set.is_remote_backed? # If FileSet is remote backed, this is remote scenario 3 or 4
      # If FileSet label filename doesn't have extension, try to find one
      if @file_set.label.present? && !File.extname(@file_set.label).present?
        @file_set.label = "#{@file_set.label}#{MorphosourceHelper::RemoteFileInfo.new(uri.to_s).file_ext}"
      end

      # Remote scenario 3
      if !@file_set.has_remote_manifest?
        if !@user.can_submit_remote_file?(uri, @file_set.parent.organization_id&.first)
          send_error('User is not allowed to submit the remote file')
          return
        end

        # Download short-lived cache copy
        download_to_external_cache(uri, auth_header)
      end

      @file_set = Hyrax.query_service.find_by(id: @file_set.id)
      upload_remote_backed(uri)
    else # Remote scenario 2
      unless BrowseEverything::Retriever.can_retrieve?(uri, auth_header)
        send_error('Expired URL')
        return
      end
      download_to_tmpdir(uri, @file_set.label, auth_header) do |f|
        @file_set = Hyrax.query_service.find_by(id: @file_set.id)
        upload_and_complete(f)
      end
    end
  end

  # Downloads to the ExternalUrl-compatible cache path (no file handle yielded).
  # Reuses the cached copy if already present (e.g. from a prior LazyHTTPFile access).
  def download_to_external_cache(uri, headers)
    path = external_url_local_path(uri.to_s)
    return if File.exist?(path)
    FileUtils.mkdir_p(File.dirname(path))
    request_headers = headers.merge(Hyrax.config.remote_request_headers)
    IO.copy_stream(URI.open(uri.to_s, request_headers), path)
  rescue StandardError => e
    send_error(e.message)
  end

  # Registers the remote URL with ValkyrieUpload for remote-backed FileSets.
  # io is intentionally nil — ExternalUrl storage ignores it and reads from the URL.
  def upload_remote_backed(uri)
    cache_path = external_url_local_path(uri.to_s)
    if cache_path.present?
      @file_set.digest = Digest::SHA1.file(cache_path).to_s
      @file_set.e_tag  = MorphosourceHelper::RemoteFileInfo.new(uri)&.e_tag
      @file_set = Hyrax.persister.save(resource: @file_set)
    end
    Hyrax::ValkyrieUpload.file(
      io: nil,
      filename: uri,
      file_set: @file_set,
      use: Hyrax::FileMetadata::Use::ORIGINAL_FILE,
      user: @user
    )
    @operation.success!
  rescue StandardError => e
    send_error(e.message)
  end

  # Downloads via BrowseEverything to a temp directory and yields the open file.
  def download_to_tmpdir(uri, name, headers)
    filename = File.basename(name)
    dir = Dir.mktmpdir
    Rails.logger.debug("ValkyrieRemoteIngestJob: Copying <#{uri}> to #{dir}")
    File.open(File.join(dir, filename), 'wb') do |f|
      request_headers = headers.merge(Hyrax.config.remote_request_headers)
      write_file(uri, f, request_headers)
      yield f
    end
  rescue StandardError => e
    send_error(e.message)
  end

  # Write file using BrowseEverything retriever (non-remote-backed files).
  def write_file(uri, f, headers)
    retriever = BrowseEverything::Retriever.new
    uri_spec = ActiveSupport::HashWithIndifferentAccess.new(url: uri, headers: headers)
    retriever.retrieve(uri_spec) do |chunk|
      f.write(chunk)
    end
    f.rewind
  end

  # Upload BrowseEverything file content to the FileSet and mark the operation successful.
  def upload_and_complete(f)
    Hyrax::ValkyrieUpload.file(
      io: f,
      filename: @file_set.label || File.basename(f.path),
      file_set: @file_set,
      use: Hyrax::FileMetadata::Use::ORIGINAL_FILE,
      user: @user
    )
    @operation.success!
  rescue StandardError => e
    send_error(e.message)
  end

  # Returns the local cache path that Valkyrie::Storage::ExternalUrl::LazyHTTPFile
  # would use for this URL, so downstream reads find the file in the same place.
  def external_url_local_path(url)
    digest = Digest::SHA256.hexdigest(url)
    basename = File.basename(URI.parse(url).path).presence || digest
    File.join(Hyrax.config.working_external_path, digest, basename)
  end

  # Fail the operation and run the failure callback.
  def send_error(error_message)
    @file_set.errors.add('Error:', error_message)
    Hyrax.config.callback.run(:after_import_url_failure, @file_set, @user)
    @operation.fail!(@file_set.errors.full_messages.join(' '))
  end
end
