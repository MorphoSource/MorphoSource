module Morphosource
  # Handles creating Valkyrie FileSets and attaching them to an ActiveFedora work.
  # Inherits the add/attach interface from Hyrax::WorkUploadsHandler, overriding
  # the pieces that differ in the hybrid AF-work / Valkyrie-FileSet architecture:
  #
  #   - User is resolved from the work via proxy_or_depositor, or supplied explicitly.
  #   - Visibility respects the work's fileset_visibility override before falling
  #     back to work_attributes or the work's own visibility.
  #   - FileSet args include the MorphoSource-specific `accessibility` attribute.
  #   - Work membership is updated via valkyrie_member_ids with a single AF save.
  #   - :after_create_fileset callback is run (instead of the Hyrax publisher event).
  #
  # Two entry points:
  #
  #   # Uploaded files (Hyrax::UploadedFile objects):
  #   Morphosource::WorkUploadsHandler.new(work: my_work, work_attributes: params)
  #     .add(files: uploaded_files)
  #     .attach
  #
  #   # Remote files (array of { url:, file_name:, mime_type_of_remote: } hashes):
  #   Morphosource::WorkUploadsHandler.new(work: my_work, user: env.user)
  #     .add_remote_files(remote_files: remote_file_hashes)
  #     .attach
  class WorkUploadsHandler < Hyrax::WorkUploadsHandler
    attr_reader :remote_files

    ##
    # @param [ActiveFedora::Base] work
    # @param [Hash] work_attributes visibility and embargo/lease params
    # @param [#save] persister
    # @param [User, nil] user optional explicit user; if nil, resolved from work
    #   via proxy_or_depositor
    def initialize(work:, persister: Hyrax.persister, work_attributes: {}, user: nil)
      super(work: work, persister: persister)
      @work_attributes = work_attributes
      @depositor_user = user
    end

    ##
    # Stage remote file info hashes for attachment via #attach.
    #
    # @param [Array<Hash>] remote_files array of { url:, file_name:, mime_type_of_remote: }
    # @return [self]
    def add_remote_files(remote_files:)
      @remote_files = Array.wrap(remote_files)
      self
    end

    ##
    # Create FileSets for each staged file and attach them to the AF work.
    # Routes to the remote-files path when add_remote_files was called,
    # otherwise uses the uploaded-files path.
    #
    # @return [Boolean] true if all requested files were attached
    def attach
      return attach_remote_files if @remote_files
      return true if Array.wrap(files).empty?

      acquire_lock_for(work.id) do
        @new_member_ids = []
        event_payloads = remote_files
          ? remote_files.map { |rf| make_remote_file_set_and_ingest(rf) }
          : files.map { |file| make_file_set_and_ingest(file) }
        work.reload unless work.new_record?
        work.valkyrie_member_ids = (work.valkyrie_member_ids.to_a + @new_member_ids).uniq
        work.save!
        event_payloads.each do |payload|
          payload.delete(:job).enqueue
          Hyrax.publisher.publish('file.set.attached', payload)
        end
      end
    end

    private

    # -- Uploaded-files path --------------------------------------------------

    def make_file_set_and_ingest(file)
      file_set = @persister.save(resource: Hyrax::FileSet.new(file_set_args(file)))
      Hyrax.publisher.publish('object.deposited', object: file_set, user: depositor_user)
      file.add_file_set!(file_set)

      file_set.visibility = visibility_for
      file_set.permission_manager.acl.save if file_set.permission_manager.acl.pending_changes?
      append_to_work(file_set)

      { file_set: file_set, user: depositor_user, job: ValkyrieIngestJob.new(file) }
    end

    def file_set_args(file)
      { depositor: depositor_user.user_key,
        creator: [depositor_user.user_key],
        date_uploaded: Hyrax::TimeService.time_in_utc,
        date_modified: Hyrax::TimeService.time_in_utc,
        label: file.uploader.filename,
        title: file.uploader.filename,
        accessibility: work.respond_to?(:fileset_accessibility) ? work.fileset_accessibility : nil }
    end

    # -- Remote-files path ----------------------------------------------------

    def make_remote_file_set(file_info)
      file_set = @persister.save(resource: Hyrax::FileSet.new(remote_file_set_attrs(file_info)))
      Hyrax.publisher.publish('object.deposited', object: file_set, user: depositor_user)

      file_set.visibility = visibility_for
      file_set.permission_manager.acl.save if file_set.permission_manager.acl.pending_changes?
      append_to_work(file_set)

      { file_set: file_set, user: depositor_user, job: ValkyrieRemoteIngestJob.new(file_set, file_info) }
    end

    def remote_file_set_attrs(file_info)
      uri = URI.parse(Addressable::URI.escape(file_info[:url]))
      attrs = { depositor: depositor_user.user_key,
                creator: [depositor_user.user_key],
                date_uploaded: Hyrax::TimeService.time_in_utc,
                date_modified: Hyrax::TimeService.time_in_utc,
                import_url: URI.decode_www_form_component(uri.to_s),
                label: file_info[:file_name],
                accessibility: work.respond_to?(:fileset_accessibility) ? work.fileset_accessibility : nil }
      attrs[:mime_type_of_remote] = file_info[:mime_type_of_remote] if file_info[:mime_type_of_remote].present?
      attrs
    end

    # -- Shared helpers -------------------------------------------------------

    # Collects the new FileSet ID for the batch work save and sets representative/thumbnail.
    def append_to_work(file_set)
      @new_member_ids << file_set.id.to_s
      work.representative_id = file_set.id.to_s if work.respond_to?(:representative_id) && work.representative_id.blank?
      work.thumbnail_id = file_set.id.to_s if work.respond_to?(:thumbnail_id) && work.thumbnail_id.blank?
    end

    # Restricted fileset_visibility on the work takes precedence; otherwise falls
    # back to the visibility param from work_attributes, then the work's own value.
    def visibility_for
      if work.respond_to?(:fileset_visibility) && work.fileset_visibility == ['restricted']
        'restricted'
      else
        visibility_attributes[:visibility] || work.visibility
      end
    end

    def visibility_attributes
      @work_attributes.slice(:visibility, :visibility_during_lease,
                             :visibility_after_lease, :lease_expiration_date,
                             :embargo_release_date, :visibility_during_embargo,
                             :visibility_after_embargo)
    end

    # Resolves the depositing user, honouring proxy-on-behalf-of relationships.
    # Skipped when an explicit user was supplied to initialize.
    def depositor_user
      @depositor_user ||= begin
        depositor = work.on_behalf_of.blank? ? work.depositor : work.on_behalf_of
        User.find_by_user_key(depositor)
      end
    end
  end
end
