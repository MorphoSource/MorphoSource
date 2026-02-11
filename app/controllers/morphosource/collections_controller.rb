module Morphosource
  class CollectionsController < Hyrax::CollectionsController
    include Morphosource::CollectionsControllerBehavior
    helper Morphosource::CollectionHelper
    include Morphosource::Facets::Collections
    include Morphosource::TemporaryAccess::TemporaryAccessControllerBehavior

    helper_method :remove_constraint_url, :body_css_classes

    with_themed_layout 'morphosource_1_column'

    skip_load_and_authorize_resource only: [
      :show, :about, :facet,
      :media_export, :media_downloads, :media_download_counts, :media_requests
    ], instance_name: :collection
    prepend_before_action :authorize_collection_with_temporary_link, only: [:show, :about]

    # Don't add breadcrumbs
    before_action :build_breadcrumbs, only: []

    before_action :load_collection, :redirect_to_collection_type, :authorize_collection

    class_attribute :can_authorize_with_temporary_link, :collection_type
    self.can_authorize_with_temporary_link = false
    self.collection_type = collection_type
    self.presenter_class = presenter_class
    self.search_state_class = Morphosource::SearchState
    self.temporary_access_link_class = TemporaryCollectionAccessLink

    def search_builder_class
      Morphosource::Collections::MediaSearchBuilder
    end

    def media_count_search_builder_class
      search_builder_class
    end

    def media_objects_search_builder_class
      Morphosource::Collections::MediaObjectsSearchBuilder
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

        config.facet_fields = {} # clear catalog facet fields
        config.add_facet_field "media_type", field: "human_readable_media_type_ssim", label: "Media Type", limit: 10
        config.add_facet_field "object", field: "physical_object_title_ssim", label: "Object", limit: 10
        config.add_facet_field "organization", field: "media_organization_ssim", label: "Organization", limit: 10
        config.add_facet_field "publication_status", field: "publication_status_ssi", label: "Publication Status", limit: 10
        config.add_facet_field "taxonomy_name", field: "taxonomy_ssim", label: "Taxonomy (Name)", limit: 10
        config.add_facet_field "team", field: "member_of_team_ids_ssim", label: "Team", limit: 10, helper_method: :collection_title_by_id
        config.add_facet_field "project", field: "member_of_project_ids_ssim", label: "Project", limit: 10, helper_method: :collection_title_by_id
        config.add_facet_field "owner", field: "user_with_ownership_name_ssim", label: "Data Manager", limit: 10
        config.add_facet_field "depositor", field: "depositor_name_ssim", label: "Data Uploader", limit: 10
        # hidden field used to determine if there are specimens on the page
        config.add_facet_field "object_type", field: "media_physical_object_type_ssim", label: "Object Type", limit: 10, show: false
      end
    end
    configure_facets

    def media_export_with_intersections_facet
      media_export
    end

    def media_download_counts_with_intersections_facet
      media_download_counts
    end

    def body_css_classes
      "showcase teams"
    end

    # allowlist sort parameters for collection media
    # see also application_controller #sanitize_sort_param
    # see also _document_list partial
    def allowed_sort_parameters
      ['date_uploaded_dtsi asc',
       'date_uploaded_dtsi desc',
       'human_readable_media_type_ssi asc',
       'human_readable_media_type_ssi desc',
       'part_ssi asc',
       'part_ssi desc',
       'physical_object_title_ssi asc',
       'physical_object_title_ssi desc',
       'publication_status_ssi asc',
       'publication_status_ssi desc',
       'short_description_ssi asc',
       'short_description_ssi desc',
       'taxonomy_ssi asc',
       'taxonomy_ssi desc']
    end

    private

      def authorize_admin
        deny_access_forbidden and return unless current_user&.admin?
      end

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

      # does the collection show page include UV preview pane? no by default
      def has_uv_preview?
        false
      end
      helper_method :has_uv_preview?

      # paginated results shown in the facet "more" modal
      # see lib/morphosource/facets/collections.rb
      def facet_search_response
        blacklight_config.repository.search(search_builder.with(params).facet(@facet.key))
      end
  end
end
