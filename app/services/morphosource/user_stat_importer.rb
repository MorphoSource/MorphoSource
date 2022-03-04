require 'retriable'

module Morphosource
  # Cache work view, file view & file download stats for all users
  # Modified from Hyrax::UserStatImporter to reduce DB bloat of rows with 0 views & downloads
  class UserStatImporter < Hyrax::UserStatImporter
    private

      def process_files(stats, user, start_date)
        file_ids_for_user(user).each do |file_id|
          file = ::FileSet.find(file_id)
          view_stats = extract_stats_for(object: file, from: FileViewStat, start_date: start_date, user: user)
          stats = tally_results(view_stats, :views, stats) if view_stats.present?
          delay
          dl_stats = extract_stats_for(object: file, from: FileDownloadStat, start_date: start_date, user: user)
          stats = tally_results(dl_stats, :downloads, stats) if dl_stats.present?
          delay
        end
      end

      def process_works(stats, user, start_date)
        media_ids_for_user(user).each do |work_id|
          work = Hyrax::WorkRelation.new.find(work_id)
          work_stats = extract_stats_for(object: work, from: WorkViewStat, start_date: start_date, user: user)
          stats = tally_results(work_stats, :work_views, stats) if work_stats.present?
          delay
        end
      end

      def media_ids_for_user(user)
        ids = []
        ::Media.search_in_batches("#{depositor_field}:\"#{user.user_key}\"", fl: "id") do |group|
          ids.concat group.map { |doc| doc["id"] }
        end
        ids
      end

      def create_or_update_user_stats(stats, user)
        newest_date = Hyrax.config.analytic_start_date
        newest_data = {}
        stats.each do |date_string, data|
          date = Time.zone.parse(date_string)
          if date > newest_date
            newest_date = date
            newest_data = data
          end

          user_stat = UserStat.where(user_id: user.id, date: date).first_or_initialize(user_id: user.id, date: date)

          user_stat.file_views = data.fetch(:views, 0)
          user_stat.file_downloads = data.fetch(:downloads, 0)
          user_stat.work_views = data.fetch(:work_views, 0)
          user_stat.save! unless (user_stat.file_views == 0 && user_stat.file_downloads == 0 && user_stat.work_views == 0)
        end

        # Ensure last user stat date DB row gets created if the user deposited media, even if no usage of those media
        # This is to allow for last-date caching to be accurate, even while usually not storing no-usage rows
        if stats.present?
          user_stat = UserStat.where(user_id: user.id, date: newest_date).first_or_initialize(user_id: user.id, date: newest_date)

          user_stat.file_views = newest_data.fetch(:views, 0)
          user_stat.file_downloads = newest_data.fetch(:downloads, 0)
          user_stat.work_views = newest_data.fetch(:work_views, 0)
          user_stat.save!
        end
      end
  end
end