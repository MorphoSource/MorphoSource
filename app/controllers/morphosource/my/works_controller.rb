module Morphosource
  module My
    class WorksController < Hyrax::My::WorksController
      include Morphosource::My::WorksControllerBehavior
      include Morphosource::Facets::Collections
      include Morphosource::My::WorksHelper
      include Morphosource::Breadcrumbs::Works

      class_attribute :create_work_presenter_class, :filtered_facets

      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter
      self.search_state_class = Morphosource::SearchState

      with_themed_layout 'morphosource_dashboard'

      before_action :tab_variables, only: [:index]

      def index
        # The user's collections for the "add to collection" form
        all_memberships_collection_ids, manager_collection_ids, editor_collection_ids, depositor_collection_ids, downloader_collection_ids, viewer_collection_ids = current_user.collections_with_membership_role_ids
        @user_collections = manager_collection_ids + editor_collection_ids + depositor_collection_ids
        add_breadcrumbs
        # media/object counts at top of page
        get_media_object_counts
        # managed_works_count
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        (@response, @document_list) = search_service.search_results
        prepare_instance_variables_for_batch_control_display
        respond_to do |format|
          format.html {
            render 'morphosource/my/works/index'
          }
        end
      end

      def sort_parameters
        s = (params[:sort].presence || '').split(' ')
        return s[0], s[1]
      end
      helper_method :sort_parameters

    end
  end
end
