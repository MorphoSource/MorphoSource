# frozen_string_literal: true

module Morphosource
  # Extends Hyrax::ValkyrieUpload with support for remote-backed (ExternalUrl) files.
  #
  # Key differences from Hyrax::ValkyrieUpload:
  #
  #   1. Nil-safe io.size — remote-backed files pass io: nil; Hyrax crashes on nil.size.
  #   2. FileMetadata creation without downloading — Hyrax's rescue branch calls
  #      file.disk_path which triggers a remote HTTP download just to get the basename.
  #      We extract the filename directly from the original filename argument.
  #   3. Label/title preservation for remote-backed files — when io is nil and the
  #      FileSet already has a label (set by the job, possibly enriched with an
  #      extension from Content-Type), we preserve it rather than overwriting with
  #      the bare URI path segment.
  class ValkyrieUpload < Hyrax::ValkyrieUpload
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/ParameterLists
    def upload(filename:, file_set:, io:,
               use: Hyrax::FileMetadata::Use::ORIGINAL_FILE,
               user: nil, mime_type: nil, skip_derivatives: false)
      return version_upload(file_set: file_set, io: io, user: user) \
        if use == Hyrax::FileMetadata::Use::ORIGINAL_FILE &&
           file_set.original_file_id &&
           storage_adapter.supports?(:versions)

      streamfile = storage_adapter.upload(file: io, original_filename: filename, resource: file_set)
      file_metadata = build_file_metadata_for(streamfile, filename: filename)
      file_metadata.file_set_id = file_set.id
      file_metadata.pcdm_use = Array(use)
      file_metadata.recorded_size = Array(io&.size) # nil-safe for ExternalUrl (io is nil)
      file_metadata.mime_type = mime_type if mime_type
      file_metadata.original_filename = original_filename_from(filename)

      if use == Hyrax::FileMetadata::Use::ORIGINAL_FILE
        # For remote-backed files (io nil), the job has already set the label,
        # possibly enriching it with an extension from the Content-Type header.
        # Preserve that label rather than overwriting with the bare URI basename.
        unless io.nil? && file_set.label.present?
          reset_title = file_set.title.blank? || file_set.title.first == file_set.label
          file_set.title = file_metadata.original_filename if reset_title
          file_set.label = file_metadata.original_filename
        end

        # In case title has not been set yet, set it now
        if file_set.title.blank? && file_set.label.present?
          file_set.title = [file_set.label]
        end
      end

      saved_metadata = Hyrax.persister.save(resource: file_metadata)
      saved_metadata.original_filename = file_metadata.original_filename if saved_metadata.original_filename.blank?

      add_file_to_file_set(file_set: file_set, file_metadata: saved_metadata, user: user)

      Hyrax.publisher.publish("file.uploaded", metadata: saved_metadata, skip_derivatives: skip_derivatives)
      Hyrax.publisher.publish('file.metadata.updated', metadata: saved_metadata, user: user,
                                                        skip_derivatives: skip_derivatives)

      saved_metadata
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/ParameterLists

    private

    # Build a FileMetadata object for the given storage file without triggering
    # a remote HTTP download.
    #
    # Hyrax::FileMetadata() falls back to File.basename(file.disk_path) in its
    # rescue path; for ExternalFiles this downloads the remote file just to get
    # its local cache path. Instead we extract the filename from the original
    # filename argument directly.
    def build_file_metadata_for(streamfile, filename:)
      Hyrax.custom_queries.find_file_metadata_by(id: streamfile.id)
    rescue Hyrax::ObjectNotFoundError, Ldp::BadRequest, Valkyrie::Persistence::ObjectNotFoundError
      Hyrax::FileMetadata.new(
        file_identifier: streamfile.id,
        original_filename: original_filename_from(filename)
      )
    end

    # Extract a plain filename string from a URI or String.
    #
    # For URI objects (remote-backed files), uses the last non-empty path
    # segment. Falls back to the hostname when the path is bare (e.g. /).
    # For Strings, delegates to File.basename.
    def original_filename_from(filename)
      if filename.is_a?(URI)
        File.basename(filename.path).presence || filename.host || filename.to_s
      else
        File.basename(filename.to_s)
      end
    end
  end
end
