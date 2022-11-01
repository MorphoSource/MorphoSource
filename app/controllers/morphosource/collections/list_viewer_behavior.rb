module Morphosource
  module Collections
    module ListViewerBehavior

      def change_slide
        ids_from_params
        target_document_presenter
        reload_viewer
      end

      # find the index of the slide currently in the viewer
      def ids_from_params
        return if params["view"] == "change"

        current_id = params["current_id"]
        @current_id_index = params["document"].index(current_id)
      end

      def target_document_presenter
        target_id
        document_list = [SolrDocument.find(@target_id)]
        media_presenter(document_list)
      end

      # render change_slide.html.erb
      def reload_viewer
        respond_to do |format|
          format.js { render layout: false }
          format.html { render 'show'}
        end
      end

      # find the id of the next slide to be loaded in the viewer
      def target_id
        @target_id = case params["view"]
        when "next"
          # if current slide is last on page, go back to the beginning
          params["document"][@current_id_index + 1] || params["document"][0]
        when "previous"
          params["document"][@current_id_index - 1]
        when "change"
          params["document"]
        end
      end

    end
  end
end