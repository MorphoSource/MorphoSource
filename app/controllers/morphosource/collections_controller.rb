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
      redirect_to '/' unless current_user&.admin?

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
      redirect_to '/' unless current_user&.admin?

      (@response, @document_list) = query_solr_all_results
      media_ids = @document_list.map{|d| d["id"]}.flatten.compact.uniq 
      downloads = Morphosource::Reports::DownloadsReportService.call(media_ids).
        group_by{|h| h['media_id'] }.map{|k, v| [k, v.length]}.to_h
      @new_document_list = @document_list.map do |doc| 
        doc.to_semantic_values.merge(downloads: ( downloads[doc['id']] || 0 ) )
      end

      respond_to do |format|
        format.csv do 
          csv_response_headers('Media%20Download%20Counts')
          render 'show'
        end
      end
    end

    def media_requests
      redirect_to '/' unless current_user&.admin?

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

    def csv_response_headers(file_name)
      response.headers['Content-Type'] = 'text/csv'
      response.headers['Content-Disposition'] = "attachment; filename=MorphoSource%20#{collection.human_readable_type}%20#{@collection.id}%20-%20#{file_name}.csv"
    end
  end
end
