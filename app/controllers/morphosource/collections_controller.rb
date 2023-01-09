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

    copy_blacklight_config_from(::MediaCatalogController)

    def self.configure_facets
      configure_blacklight do |config|
        config.http_method = :post
        config.search_builder_class = self.new.search_builder_class
        # clear catalog facet fields
        config.facet_fields = {}
        config.add_facet_field "publication_status_ssi", label: "Publication Status", limit: 10
        config.add_facet_field "human_readable_media_type_ssim", label: "Media Type", limit: 10
        config.add_facet_field "physical_object_title_ssim", label: "Object", limit: 10
        config.add_facet_field "media_organization_ssim", label: "Organization", limit: 10
        config.add_facet_field "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
        config.add_facet_field "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
        config.add_facet_field "user_with_ownership_ssi", label: "Data Manager", limit: 10, helper_method: :user_name_by_id
        config.add_facet_field "depositor_ssim", label: "Depositor", limit: 10, helper_method: :user_name_by_id
      end
    end
    configure_facets

    def media_export_with_intersections_facet
      media_export
    end

    def media_download_counts_with_intersections_facet
      media_download_counts
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

      # this creates the url to remove a search query term
      # only called if search term exists
      def remove_constraint_url(localized_params)
        localized_params.delete(:route_set)
        unless localized_params.is_a? ActionController::Parameters
          localized_params = ActionController::Parameters.new(localized_params)
        end
        options = localized_params.merge(q: nil, action: 'show')
        options.permit!
        main_app.url_for(options)
      end
      helper_method :remove_constraint_url
  end
end
