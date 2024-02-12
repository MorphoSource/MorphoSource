module Morphosource
  module My
    class AddMediaController < MediaController

      rescue_from ActiveFedora::ObjectNotFoundError, with: :collection_not_found

      with_themed_layout 'morphosource_1_column'

      before_action :authorize_collection_access, except: [:facet]

      def search_builder_class
        unless @collection.present?
          # e.g. called from filter works > more link
          @collection = Collection.find(params["collection_id"])
        end
        @collection.search_builder_class
      end

      def index
        # The user's collections for the "add to collection" form
        case @collection.human_readable_type
        when "Sequential Section List"
          @user_collections = sequential_section_lists_service.search_results(:deposit)
        when "Media List"
          @user_collections = media_lists_service.search_results(:deposit)
        else
          @user_collections = collections_service.search_results(:deposit)
        end
        # media/object counts at top of page
        get_media_object_counts
        # managed_works_count
        @create_work_presenter = create_work_presenter_class.new(current_user)
        @user = current_user
        (@response, @document_list) = query_solr
        prepare_instance_variables_for_batch_control_display
        respond_to do |format|
          format.html {
            render 'morphosource/my/works/index'
          }
        end
      end

      private

        def authorize_collection_access
          authorize! :edit, @collection
        end

        def search_action_url(*args)
          main_app.my_add_media_index_path(*args)
        end

        # The url of the "more" link for additional facet values
        def search_facet_path(args = {})
          main_app.my_dashboard_add_media_facet_path({:collection_id => params["collection_id"], :id =>  args[:id]})
        end

        def tab_variables
          @collection = Collection.find(params[:collection_id])
          @tab = :add_media
          @page_title = t("morphosource.dashboard.my.add_media.title") + @collection.title.first
          @add_to_collection_button_label = t("morphosource.dashboard.my.add_media.add_media_button") + @collection.title.first
          @tab_title = 'Add Media // MorphoSource'
        end

        def collection_not_found
          redirect_to main_app.my_media_index_path, alert: "Collection '#{params[:collection_id]}' does not exist"
        end

    end
  end
end
