module Morphosource
  class CollectionsController < Hyrax::CollectionsController
    include Morphosource::CollectionsControllerBehavior
    helper Morphosource::CollectionHelper
    include Morphosource::Facets::Collections

    helper_method :remove_constraint_url, :body_css_classes

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

    def media_export_with_intersections_facet
      media_export
    end

    def media_download_counts_with_intersections_facet
      media_download_counts
    end

    def body_css_classes
      "showcase teams"
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

      def sort_parameters
        s = (params[:sort].presence || '').split(' ')
        return s[0], s[1]
      end
      helper_method :sort_parameters

      def remove_constraint_url(localized_params)
        localized_params.delete(:route_set)
        unless localized_params.is_a? ActionController::Parameters
          localized_params = ActionController::Parameters.new(localized_params)
        end
        options = localized_params.merge(q: nil, action: 'show')
        options.permit!
        main_app.url_for(options)
      end
  end
end
