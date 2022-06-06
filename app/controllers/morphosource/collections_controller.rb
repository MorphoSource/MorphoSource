module Morphosource
  class CollectionsController < Hyrax::CollectionsController
    include Morphosource::CollectionsControllerBehavior
    helper Morphosource::CollectionHelper
    include Morphosource::Facets::Collections

    with_themed_layout 'morphosource_1_column'

    skip_load_and_authorize_resource only: [:show, :about, :facet], instance_name: :collection

    # Don't add breadcrumbs
    before_action :build_breadcrumbs, only: []

    before_action :load_collection, :redirect_to_collection_type

    self.presenter_class = presenter_class


    def search_builder_class
      Morphosource::Collections::MediaSearchBuilder
    end

    def self.remove_bookmarks
      configure_blacklight do |config|
        config.index.document_actions.delete(:bookmark)
        config.show.document_actions.delete(:bookmark)
      end
    end
    remove_bookmarks

    def media_downloads
      redirect_to '/' unless current_ability.can?(:edit, @collection)

      repository.blacklight_config.max_per_page = 9999999
      (@response, @document_list) = query_solr_all_results
      media_ids = @document_list.map{|d| d["id"]}.flatten.compact.uniq 
      @new_document_list = Morphosource::Reports::DownloadsReportService.call(media_ids)

      respond_to do |format|
        format.csv do 
          csv_response_headers('Media%20Downloads')
          render 'show'
        end
      end
    end

    def media_download_counts
      redirect_to '/' unless current_ability.can?(:edit, @collection)

      repository.blacklight_config.max_per_page = 9999999
      (@response, @document_list) = query_solr_all_results
      media_ids = @document_list.map{|d| d["id"]}.flatten.compact.uniq 
      downloads = Morphosource::Reports::DownloadsReportService.call(media_ids)
      
      user_demographics = downloads.pluck('download_user_id').uniq.map do |user_id|
        [user_id, User.find_by_user_key(user_id)&.demographics ]
      end.to_h

      download_counts_by_media = downloads.group_by{|h| h['media_id'] }.map do |media_id, dls|
        [ media_id, download_counts_hash(dls, user_demographics) ]
      end.to_h

      @new_document_list = @document_list.map do |doc| 
        doc.to_semantic_values.merge(
          download_counts_by_media[doc['id']] || download_counts_hash([], [])
        )
      end

      respond_to do |format|
        format.csv do 
          csv_response_headers('Media%20Download%20Counts')
          render 'show'
        end
      end
    end

    def media_requests
      redirect_to '/' unless current_ability.can?(:edit, @collection)

      repository.blacklight_config.max_per_page = 9999999
      (@response, @document_list) = query_solr_all_results
      media_ids = @document_list.map{|d| d["id"]}.flatten.compact.uniq 
      @new_document_list = Morphosource::Reports::RequestsReportService.call(media_ids)

      respond_to do |format|
        format.csv do 
          csv_response_headers('Media%20Requests')
          render 'show'
        end
      end
    end
    
    private

    def decide_layout
      layout = case action_name
               when 'show'
                 'morphosource_1_column'
               else
                 'dashboard'
               end
      File.join(theme, layout)
    end

    def download_counts_hash(downloads, user_demographics)
      {
        downloads: downloads.length,
        unique_download_users: downloads.pluck('download_user_id').uniq.compact.count,
      }.merge(
        download_categories(downloads, user_demographics)
      )
    end

    def download_categories(downloads, user_demographics)
      result = empty_category_hash.deep_dup

      downloads_by_user = downloads.group_by{|h| h['download_user_id'] }
      downloads_by_user.map do |user_id, user_downloads|
        # download usage intents
        use_intents = user_downloads.pluck('download_usage_list').map { |x| x&.split(';') }.flatten.uniq.compact
        use_intents.each { |cat| result[cat] += 1 if result.key?(cat) }
        # user demographics
        demographics = user_demographics[user_id]
        demographics.each { |cat| result[cat] += 1 if result.key?(cat) } if demographics.present?
      end

      result
    end

    def empty_category_hash
      @empty_category_hash ||= {}.
        merge('unique_download_user_usage_intent_counts' => nil ).
        merge(Morphosource::UserProfile::CheckboxValues::INTENT.map { |term| [term, 0] }.to_h).
        merge('uniq_download_user_demographic_counts' => nil).
        merge(Morphosource::UserProfile::CheckboxValues::DEMOGRAPHICS.map { |term| [term, 0] }.to_h)
    end

    def csv_response_headers(file_name)
      response.headers['Content-Type'] = 'text/csv'
      response.headers['Content-Disposition'] = "attachment; filename=MorphoSource%20#{collection.human_readable_type}%20#{@collection.id}%20-%20#{file_name}.csv"
    end

    def sort_parameters
      s = (params[:sort].presence || '').split(' ')
      return s[0], s[1]
    end
    helper_method :sort_parameters
  end
end
