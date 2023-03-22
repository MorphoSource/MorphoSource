module Morphosource
  module My
    class CollectionsController < Hyrax::My::CollectionsController

      helper_method :remove_constraint_url, :search_action_for_dashboard

      before_action :build_breadcrumbs, only: []
      before_action :create_membership_facet

      with_themed_layout 'morphosource_dashboard'

      # Define collection specific filter facets.
      def self.configure_facets
        configure_blacklight do |config|
          config.http_method = :post
          config.search_builder_class = self.new.search_builder_class
          # clear catalog facet fields
          config.facet_fields = {}
          # membership facet added in before_action :create_membership_facet
          config.add_facet_field "visibility_ssi", label: "Visibility", limit: 10, helper_method: :visibility_label
          config.add_facet_field "human_readable_type_ssim", label: "Collection Type", limit: 10
        end
      end
      configure_facets

      def search_builder_class
       Morphosource::My::CollectionsSearchBuilder
      end

      def index
        @collections_type = collections_type
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_collection_type_breadcrumb
        collection_type_list_presenter
        managed_collections_count
        @user = current_user
        Deprecation.silence(Hyrax::MyController) do
          (@response, @document_list) = query_solr
        end
        @collection_counts = collection_counts
        prepare_instance_variables_for_batch_control_display

        respond_to do |format|
          format.html {}
        end
      end

      private

      # uses the membership facet to get total counts for each category
      def collection_counts
        @response.facet_queries.each_with_object({}) do |(k,v), counts|
          if k.include? 'edit_access_group_ssim'
            counts["Manager"] = v if v > 0
          elsif k.include? 'read_access_group_ssim'
            # byebug
            if k.include? '_editors'
              counts["Editor"] = v if v > 0
            elsif k.include? '_depositors'
              counts["Depositor"] = v if v > 0
            elsif k.include? '_downloaders'
              counts["Downloader"] = v if v > 0
            elsif k.include? '_viewers'
              counts["Viewer"] = v if v > 0
            end
          end
        end
      end

      def create_membership_facet
        groups = current_user.groups - ['admin']

        editor_groups = current_user.editor_groups.empty? ? ['none'] : current_user.editor_groups
        depositor_groups = current_user.depositor_groups.empty? ? ['none'] : current_user.depositor_groups
        downloader_groups = current_user.downloader_groups.empty? ? ['none'] : current_user.downloader_groups
        viewer_groups = current_user.viewer_groups.empty? ? ['none'] : current_user.viewer_groups

        config = repository.blacklight_config
        config.add_facet_field 'membership', label: 'Membership', query: {
          manager: {
            label: 'Manager',
            fq: "(edit_access_group_ssim:(#{groups.join(' OR ')}))" },
          editor: {
            label: 'Editor',
            fq: "(read_access_group_ssim:(#{editor_groups.join(' OR ')}))" },
          depositor: {
            label: 'Depositor',
            fq: "(read_access_group_ssim:(#{depositor_groups.join(' OR ')}))" },
          downloader: {
            label: 'Downloader',
            fq: "(read_access_group_ssim:(#{downloader_groups.join(' OR ')}))" },
          viewer: {
            label: 'Viewer',
            fq: "(read_access_group_ssim:(#{viewer_groups.join(' OR ')}))" }
        }
        end

        def add_collection_type_breadcrumb
          add_breadcrumb t(:'hyrax.admin.sidebar.collections'), hyrax.my_collections_path
        end

        def search_action_url(*args)
          hyrax.my_collections_url(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          hyrax.my_dashboard_collections_facet_path(args[:id])
        end

        def collection_type_list_presenter
          @collection_type_list_presenter ||= Hyrax::SelectCollectionTypeListPresenter.new(current_user)
        end

        def managed_collections_count
          @managed_collection_count = Hyrax::Collections::ManagedCollectionsService.managed_collections_count(scope: self)
        end

        def remove_constraint_url(localized_params)
          localized_params.delete(:route_set)
          unless localized_params.is_a? ActionController::Parameters
            localized_params = ActionController::Parameters.new(localized_params)
          end
          options = localized_params.merge(q: nil, action: 'index')
          options.permit!
          main_app.url_for(options)
        end
    end
  end
end