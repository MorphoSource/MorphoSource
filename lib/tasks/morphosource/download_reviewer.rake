# Rake tasks supporting the migration from the stored `download_reviewer` field
# to structured reviewer metadata on Media and OrganizationCollection.

namespace :morphosource do
  namespace :download_reviewer do
    desc 'Snapshot current download reviewer values and resolution (read-only). ' \
         'Usage: rake "morphosource:download_reviewer:export[/path/to/export.csv,all]" ' \
         '-- scope is all, organizations, media or cart_items'
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
  end
end
