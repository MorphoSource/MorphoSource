module Morphosource
  module My
    class AddMediaController < MediaController

      private

        def tab_variables
          @tab = :add_media
          @collection = Collection.find(params[:collection_id])
          @page_title = "Select existing media to include in " + @collection.title.first
          @add_to_collection_button_label = "Add media to " + @collection.title.first
          @batch_actions_partial = 'morphosource/my/media/batch_actions_add_to_collection'
        end

    end
  end
end
