module Morphosource
  module My
    class WorksController < Hyrax::My::WorksController
      include WorksControllerBehavior
      include Morphosource::My::WorksHelper

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      with_themed_layout 'morphosource_dashboard'

      before_action :save_tab, only: [:index]

      def index
        # The user's collections for the "add to collection" form
        @user_collections = collections_service.search_results(:deposit)
        add_breadcrumbs
        # media/object counts at top of page
        get_media_object_counts
        # managed_works_count
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        (@response, @document_list) = query_solr
        prepare_instance_variables_for_batch_control_display
        index_response
      end

      def index_response
        respond_to do |format|
          format.html {
            render 'morphosource/my/works/index'
          }
          format.rss  { render layout: false }
          format.atom { render layout: false }
        end
      end


    end
  end
end
