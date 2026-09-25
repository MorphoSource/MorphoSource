class BackfillMediaDownloadReviewers < ActiveRecord::Migration[6.1]
  # Fedora writes cannot roll back with the schema_migrations transaction.
  disable_ddl_transaction!

  def up
    unless Media.instance_methods.include?(:download_reviewer=) && Media.instance_methods.include?(:reviewer)
      raise 'Media reviewer backfill must run before the download_reviewers read-path cutover'
    end

    @organizations = {}
    processed = 0
    written = 0
    unchanged = 0
    orphaned = 0
    failed = 0
    dropped = 0

    Morphosource::MediaReviewerBatches.each do |ids|
      ids.each do |id|
        processed += 1
        begin
          media = Media.find(id)
        rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
          orphaned += 1
          say "#{id}: in Solr but deleted from Fedora; skipped", true
          next
        end

        # A save would normalize these values and enqueue the old CartItem reviewer job.
        legacy = Array(media.download_reviewer)
        if legacy.flat_map { |value| value.split(',') }.to_set != legacy.to_set
          failed += 1
          say "#{id}: comma-joined or blank download_reviewer requires repair before backfill", true
          next
        end

        stored = legacy.reject(&:blank?).uniq
        users = stored.present? ? User.where(ms_id: stored).pluck(:ms_id) : []
        rejected = stored - users
        if rejected.any?
          dropped += 1
          report_dropped(media.id, rejected)
        end

        if Array(media.record_download_reviewer_users).sort == users.sort
          unchanged += 1
          next
        end

        media.record_download_reviewer_users = users
        media.skip_reviewer_event = true
        if media.save
          written += 1
        else
          failed += 1
          say "#{id}: #{media.errors.full_messages.join('; ')}", true
        end
      rescue StandardError => e
        say "#{id}: #{e.class}: #{e.message}", true
        raise
      end

      say "Media processed: #{processed}; written: #{written}; unchanged: #{unchanged}; failed: #{failed}"
    end

    say "Media with dropped values: #{dropped}"
    say "Deleted Media still in Solr, skipped: #{orphaned}"
    raise "#{failed} Media could not be back filled" if failed.positive?

    say 'Complete synchronously. Re-run before the read-path cutover with writes quiesced, then verify_media.'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def report_dropped(media_id, values)
    uncached_ids = values.reject { |id| @organizations.key?(id) }
    if uncached_ids.any?
      OrganizationCollection.where(id: uncached_ids).each do |organization|
        @organizations[organization.id] = organization
      end
    end

    organizations = values.map { |id| @organizations[id] }.compact
    organizations.each do |organization|
      say "#{media_id}: dropped OrganizationCollection #{organization.id}; " \
          "current reviewers: #{organization.media_download_reviewers.inspect}", true
    end

    unresolved = values - organizations.map(&:id)
    say "#{media_id}: dropped unresolvable values: #{unresolved.inspect}", true if unresolved.any?
  end
end
