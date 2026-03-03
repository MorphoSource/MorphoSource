# frozen_string_literal: true

# Ingest a local file into a FileSet.
# Handles both AF FileSets (legacy) and Valkyrie FileSets.
# For Valkyrie FileSets, uses Hyrax::ValkyrieUpload instead of FileSetActor.
class IngestLocalFileJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet, Hyrax::FileSet] file_set
  # @param [String] path
  # @param [User] user
  def perform(file_set, path, user)
    __perform(file_set, path, user)
  end

  private

  def __perform(file_set, path, user)
    if file_set.is_a?(Hyrax::Resource)
      if file_set.label.blank?
        file_set.label = File.basename(path)
        file_set = Hyrax.persister.save(resource: file_set)
      end
      Hyrax::ValkyrieUpload.file(
        io: File.open(path),
        filename: file_set.label,
        file_set: file_set,
        use: Hyrax::FileMetadata::Use::ORIGINAL_FILE,
        user: user
      )
      Hyrax.config.callback.run(:after_import_local_file_success, file_set, user, path, warn: false)
    else
      file_set.label ||= File.basename(path)
      actor = Hyrax::Actors::FileSetActor.new(file_set, user)
      if actor.create_content(File.open(path))
        Hyrax.config.callback.run(:after_import_local_file_success, file_set, user, path, warn: false)
      else
        Hyrax.config.callback.run(:after_import_local_file_failure, file_set, user, path, warn: false)
      end
    end
  rescue SystemCallError
    # Generic rescue for Errno constants raised when accessing files.
    # @see https://ruby-doc.org/core-2.5.3/Errno.html
    Hyrax.config.callback.run(:after_import_local_file_failure, file_set, user, path, warn: false)
  end
end
