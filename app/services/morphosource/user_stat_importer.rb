require 'retriable'

module Morphosource
  # Cache work view, file view & file download stats for all users
  # Modified from Hyrax::UserStatImporter to reduce DB bloat of rows with 0 views & downloads
  class UserStatImporter < Hyrax::UserStatImporter
    
    def import
      log_message('Begin import of User stats.')

      sorted_users.each do |user|
        start_date = date_since_last_cache(user)
        # this user has already been processed today continue without delay
        next if start_date.to_date >= Time.zone.today

        stats = {}

        # process_files(stats, user, start_date) # Hyrax processes FileSet, we don't need this
        process_works(stats, user, start_date)
        create_or_update_user_stats(stats, user)
      end
      log_message('User stats import complete.')
    end
    
    private

      def process_works(stats, user, start_date)
        media_ids_for_user(user).each do |work_id|
          work = Hyrax::WorkRelation.new.find(work_id)
          work_stats = extract_stats_for(object: work, from: WorkViewStat, start_date: start_date, user: user)
          stats = tally_results(work_stats, :work_views, stats) if work_stats.present?
          delay
        end
      end

      # This method tries multiple times and finally raises the exception
      # Hyrax version rescued errors but causes bug because it returns true to tally_results
      # Might fix this later, but for now raising error to diagnose issues
      def rescue_and_retry(fail_message)
        Retriable.retriable(retry_options) do
          return yield
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
          if ( date > newest_date ) && ( date < Time.zone.today )
            newest_date = date
            newest_data = data
          end

          user_stat = UserStat.where(user_id: user.id, date: date).first_or_initialize(user_id: user.id, date: date)

          user_stat.file_views = data.fetch(:views, 0)
          user_stat.file_downloads = data.fetch(:downloads, 0)
          user_stat.work_views = data.fetch(:work_views, 0)
          user_stat.save! unless ( date == Time.zone.today || (user_stat.file_views == 0 && user_stat.file_downloads == 0 && user_stat.work_views == 0) )
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