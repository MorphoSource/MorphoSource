module Morphosource
  module My
    class AddMediaController < MediaController

      rescue_from ActiveFedora::ObjectNotFoundError, with: :collection_not_found

      before_action :authorize_collection_access, except: [:facet]

      # Only display sequential section scan media for sequential section lists
      # Only display media belonging to the same object
      def search_builder_class
        if @collection.sequential_section_list?
          Morphosource::Users::EditMedia::EditSequentialSectionScansSearchBuilder
        else
          Morphosource::Users::EditMediaSearchBuilder
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
