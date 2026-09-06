class BackfillMediaDownloadReviewers < ActiveRecord::Migration[6.1]
  # Fedora writes cannot roll back with the schema_migrations transaction.
  disable_ddl_transaction!

  def up
    unless Media.instance_methods.include?(:download_reviewer=) && Media.instance_methods.include?(:reviewer)
      raise 'Media reviewer backfill must run before the ticket 5 read-path cutover'
    end

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

        stored = Array(media.download_reviewer).reject(&:blank?).uniq
        users = stored.present? ? User.where(ms_id: stored).pluck(:ms_id) : []
        rejected = stored - users
        if rejected.any?
          dropped += 1
          report_dropped(media.id, rejected)
        end

        # A save would split these values and enqueue the old CartItem reviewer job.
        if Array(media.download_reviewer).any? { |value| value.include?(',') }
          failed += 1
          say "#{id}: comma-joined download_reviewer requires repair before backfill", true
          next
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
      end

      say "Media processed: #{processed}; written: #{written}; unchanged: #{unchanged}; failed: #{failed}"
    end

    say "Media with dropped values: #{dropped}"
    say "Deleted Media still in Solr, skipped: #{orphaned}"
    raise "#{failed} Media could not be back filled" if failed.positive?

    say 'Complete synchronously. Re-run before ticket 5 with writes quiesced, then verify_media.'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def report_dropped(media_id, values)
    organizations = OrganizationCollection.where(id: values).to_a
    organizations.each do |organization|
      say "#{media_id}: dropped OrganizationCollection #{organization.id}; " \
          "current reviewers: #{organization.media_download_reviewers.inspect}", true
    end

    unresolved = values - organizations.map(&:id)
    say "#{media_id}: dropped unresolvable values: #{unresolved.inspect}", true if unresolved.any?
  end
end
