module Morphosource
  class CollectionsController < Hyrax::CollectionsController
    include Morphosource::CollectionsControllerBehavior
    helper Morphosource::CollectionHelper
    include Morphosource::Facets::Collections

    with_themed_layout 'morphosource_1_column'

    skip_load_and_authorize_resource only: [
      :show, :about, :facet, 
      :media_export, :media_downloads, :media_download_counts, :media_requests
    ], instance_name: :collection
    
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

    def sort_parameters
      s = (params[:sort].presence || '').split(' ')
      return s[0], s[1]
    end
    helper_method :sort_parameters
  end
end
