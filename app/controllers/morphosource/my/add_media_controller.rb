module Morphosource
  module My
    class AddMediaController < MediaController

      private

        def tab_variables
          @tab = :add_media
          @collection = Collection.find(params[:collection_id])
          @page_title = t("morphosource.dashboard.my.add_media.title") + @collection.title.first
          @add_to_collection_button_label = t("morphosource.dashboard.my.add_media.add_media_button") + @collection.title.first
        end

    end
  end
end
