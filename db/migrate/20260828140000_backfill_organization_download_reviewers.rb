class BackfillOrganizationDownloadReviewers < ActiveRecord::Migration[6.1]
  MANAGERS_ARE_DOWNLOAD_REVIEWERS =
    ::RDF::URI.new('https://www.morphosource.org/terms/managersAreDownloadReviewers').freeze

  # Records an explicit download reviewer mode on every OrganizationCollection, from the
  # download_reviewer values live at this deploy.

  def up
    # After the cutover this name is the resolved getter, which would freeze Managers in.
    unless OrganizationCollection.instance_methods.include?(:download_reviewer=)
      raise 'OrganizationCollection no longer stores download_reviewer; this migration reads ' \
            'that property and must not run after the cutover deploy'
    end

    docs = ActiveFedora::SolrService.query('has_model_ssim:OrganizationCollection', rows: 999_999)
    say "OrganizationCollections: #{docs.count}"

    custom_mode = 0
    manager_mode = 0
    unchanged = 0
    dropped = []
    orphaned = []
    failed = []

    docs.each do |doc|
      begin
        organization = OrganizationCollection.find(doc['id'])
      rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
        # Deleted from Fedora, delete never reached Solr. Not this migration's failure.
        orphaned << doc['id']
        next
      end

      stored = Array(organization.download_reviewer).reject(&:blank?)
      # Matches the filter media_download_reviewers applies today.
      resolvable = stored.present? ? User.where(ms_id: stored).pluck(:ms_id) : []
      dropped << "#{organization.id}: #{(stored - resolvable).join(', ')}" if (stored - resolvable).any?

      managers_review = resolvable.empty?
      if managers_review
        manager_mode += 1
      else
        custom_mode += 1
      end

      # Re-run at the cutover deploy. Compares the persisted value, not the reader.
      if stored_managers_flag(organization) == managers_review &&
         Array(organization.custom_download_reviewer_users).sort == resolvable.sort
        unchanged += 1
        next
      end

      # The reader answers true for a blank field, so without this the write is dropped.
      organization.managers_are_download_reviewers_will_change!
      organization.managers_are_download_reviewers = managers_review
      organization.custom_download_reviewer_users = resolvable
      # Resolution is unchanged, so the event would carry no news.
      organization.skip_reviewer_event = true
      failed << "#{organization.id}: #{organization.errors.full_messages.join('; ')}" unless organization.save
    end

    say "Managers are the reviewers: #{manager_mode}"
    say "Custom reviewers recorded: #{custom_mode}"
    say "Already in target state, skipped: #{unchanged}"
    say "Stored ms_ids dropped because no User row matched: #{dropped.count}"
    dropped.each { |line| say line, true }

    say "Deleted organizations still in the index, skipped: #{orphaned.count}"
    orphaned.each { |id| say id, true }

    say "Failed: #{failed.count}"
    failed.each { |line| say line, true }
    raise "#{failed.count} organizations could not be back filled" if failed.any?
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # The reader answers true for a blank field and cannot distinguish it from a written true.
  def stored_managers_flag(organization)
    organization.resource
                .query([organization.rdf_subject, MANAGERS_ARE_DOWNLOAD_REVIEWERS, nil])
                .to_a.first&.object&.object
  end
end
