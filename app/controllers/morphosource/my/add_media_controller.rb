module Morphosource
  module My
    class AddMediaController < MediaController

      rescue_from ActiveFedora::ObjectNotFoundError, with: :collection_not_found

      before_action :authorize_collection_access

      private

        def authorize_collection_access
          authorize! :edit, @collection
        end

        def search_action_url(*args)
          main_app.my_add_media_index_path(*args)
        end

        def tab_variables
          @collection = Collection.find(params[:collection_id])
          @tab = :add_media
          @page_title = t("morphosource.dashboard.my.add_media.title") + @collection.title.first
          @add_to_collection_button_label = t("morphosource.dashboard.my.add_media.add_media_button") + @collection.title.first
        end

        def collection_not_found
          redirect_to main_app.my_media_index_path, alert: "Collection '#{params[:collection_id]}' does not exist"
        end

    end
  end
end
