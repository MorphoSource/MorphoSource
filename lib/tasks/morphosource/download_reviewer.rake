# Rake tasks supporting the migration from the stored `download_reviewer` field
# to structured reviewer metadata on Media and OrganizationCollection.

namespace :morphosource do
  namespace :download_reviewer do
    desc 'Compare Media reviewer backfill fields and resolution against live legacy values (read-only, before ticket 5)'
    task verify_media: :environment do
      verification = Morphosource::MediaReviewerVerification.new
      verification.call
      verification.summary_lines.each { |line| puts line }
      abort('verify_media found differences requiring review') unless verification.verified?
    end

    desc 'Reindex every indexed Media synchronously before ticket 5; rerun to recover from failures'
    task reindex_media: :environment do
      processed = 0
      failed = 0
      Morphosource::MediaReviewerBatches.each do |ids|
        ids.each do |id|
          begin
            Media.find(id).update_index
          rescue StandardError => e
            failed += 1
            Rails.logger.error("[morphosource:download_reviewer:reindex_media] #{id}: #{e.class}: #{e.message}")
          ensure
            processed += 1
          end
        end
        Rails.logger.info("[morphosource:download_reviewer:reindex_media] processed #{processed}; failed #{failed}")
      end
      puts "Media reindex complete: processed #{processed}; failed #{failed}"
      abort('reindex_media had failures; repair and rerun before cutover') if failed.positive?
    end

    desc 'Snapshot current download reviewer values and resolution (read-only). ' \
         'Usage: rake "morphosource:download_reviewer:export[/path/to/export.csv,all]" -- scope is all, organizations or media'
    task :export, [:path, :scope] => :environment do |task, args|
      if args[:path].blank?
        raise ArgumentError, 'morphosource:download_reviewer:export requires an export path, e.g. ' \
                             'rake "morphosource:download_reviewer:export[/data/download_reviewer_export.csv]"'
      end

      exporter = Morphosource::DownloadReviewerExport.new(
        path: args[:path],
        scope: args[:scope].presence || 'all'
      )
      exporter.call

      exporter.summary_lines.each { |line| puts line }
    end

    desc 'Check the backfilled reviewer fields against the stored download_reviewer on every ' \
         'OrganizationCollection, and the new download_reviewers getter against ' \
         'media_download_reviewers (read-only). Only meaningful until ticket 5 folds the two ' \
         'together. Usage: rake morphosource:download_reviewer:verify_organizations'
    task verify_organizations: :environment do
      verification = Morphosource::OrganizationReviewerVerification.new
      verification.call

      verification.summary_lines.each { |line| puts line }
      abort('verify_organizations found organizations the backfill did not copy correctly') unless verification.verified?
    end
  end
end
