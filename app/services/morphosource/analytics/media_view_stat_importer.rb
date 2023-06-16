require 'retriable'

module Morphosource
  module Analytics
    class MediaViewStatImporter
      include SolrHelper

      def initialize(options = {})
        if options[:verbose]
          stdout_logger = Logger.new(STDOUT)
          stdout_logger.level = Logger::INFO
          Rails.logger.extend(ActiveSupport::Logger.broadcast(stdout_logger))
        end
        @logging = options[:logging]

        @delay_secs = options[:delay_secs].to_f
        @retries = options[:retries].to_i
        
        @media_group_size = options[:media_group_size] || 50
        @limit = options[:limit] || 10_000

        @start_date = options[:start_date] || default_start_date
        @end_date = options[:end_date] || default_end_date

        @solr = solr_service.new
      end

      def import
        log_message("Begin import of Google Analytics pageviews for Media works.")

        docs = solr.get_docs("has_model_ssim:Media", { rows: 999_999, fl: ["id", "depositor_tesim"] })
        @media_ids = docs.map { |d| d["id"] }
        @media_id_to_depositor = docs.map { |d| [ d["id"], d["depositor_tesim"]&.first ] }.to_h
        log_message("#{docs.count} Media found, beginning import of chunked Media groups.")

        @media_ids.each_slice(@media_group_size).with_index do |ids_to_query, idx|
          log_message("Importing Media group #{idx} with Media IDs: #{ids_to_query.join(", ")}")
          paths = ids_to_query.map(&:media_path)

          ga_results = get_all_pageview_results(paths)
          sorted_results = group_results_by_id_and_date(ga_results)
          save_statistics(sorted_results, media_ids)
        end
      end

      private

      # Date after last WorkViewStat date (if any) or Jan 1 2021
      def default_start_date
        WorkViewStat.any? 
          ? ( WorkViewStat.order('date DESC').first.date.to_date + 1.day ) 
          : "2021/01/01".to_date
      end

      # Yesterday
      def default_end_date
        Date.current - 1.day
      end

      def profile
        @profile ||= Hyrax::Analytics.profile
      end

      def media_path(id)
        "media/#{id}"
      end

      def get_all_pageview_results(paths)
        offset = 1

        # initial query
        q, results = get_some_pageview_results(paths, offset)
        
        # if additional pages, page through results
        while q.count == @limit
          offset += @limit
          q, results = get_some_pageview_results(paths, offset, results)
        end

        return results
      end

      def get_some_pageview_results(paths, offset = 1, results = [])
        q = ga_pageview_query(paths, offset)
        results.concat(q.to_a)
        delay
        return q, results   
      end

      def ga_pageview_query(paths, offset = 1)
        retry_n ||= 0
        @profile.morphosource__analytics__pageview(
          start_date: @start_date, 
          end_date: @end_date,
          limit: @limit,
          offset: offset,
          sort: 'date'
        ).for_paths(*paths)
      rescue Exception => e
        log_message(e)
        retry_n += 1
        retry if ( retry_n < @retries )
        raise "Maximum number of retries reached in get GA pageview results: #{e.message}"
      end

      def log_message(message)
        Rails.logger.info "#{self.class}: #{message}" if @logging
      end

      def delay
        sleep @delay_secs
      end

      # Sort Google Analytics query results by media ID
      #
      # @param results [Array] Legato OpenStructs conforming to Morphosource::Analytics::Pageview 
      # @return [Hash] Nested hash with structure media ID => date => [Pageview OpenStructs]
      def group_results_by_id_and_date(results)
        results.group_by { |res| id_from_path(res.pagePath) }.transform_values do |val|
          val.group_by(&:date)
        end
      end

      # Get media ID from URL string assuming ID present in form "media/#{id}"
      def id_from_path(path)
        id = path.partition("media/").last[0...9]
        return id if (id.length == 9 && Integer(id)) rescue raise "Could not convert path #{path} to media ID" 
      end

      # Save WorkViewStat with summed pageviews per media per date
      def save_statistics(results)
        return unless results.present? && (results & @media_ids).present? && !(results - @media_ids).present?

        # For each media on each date, sum pageviews and save
        results.each do |media_id, date_results|
          date_results.each do |date, path_pageviews|
            pageviews = path_pageviews.pluck(:pageviews).map { |n| n.to_i }.sum
            if (
              (date.to_date != Date.current) && 
              pageviews.present? && 
              media_id.present? &&
              @media_id_to_depositor[media_id].present?
            )
              Morphosource::Analytics::WorkViewStat.create(
                date: date.to_date,
                work_views: pageviews,
                work_id: media_id,
                user_id: @media_id_to_depositor[media_id]
              )
            else
              raise "Something went wrong saving statistics for media ID #{media_id} with pageviews #{pageviews} on date #{date}"
            end
          end
        end
      end
    end
  end
end