module Morphosource
  module My
    module MediaControllerBehavior
      extend ActiveSupport::Concern

      def adding_to_collection?
        request.params["add_works_to_collection_label"].present?
      end

      def add_to_collection_button_label
        if adding_to_collection?
          @add_to_collection_button_label = "Add media to " + @add_to_collection_title
        else
          @add_to_collection_button_label = t('hyrax.dashboard.my.action.add_to_collection')
        end
      end

      def add_to_collection_title
        @add_to_collection_title = request.params["add_works_to_collection_label"].first.html_safe
      end

      def media_works_page_title
        @media_works_page_title = "Select existing media to include in " + @add_to_collection_title
      end

      def batch_actions_partial
        @batch_actions_partial = adding_to_collection? ? 'batch_actions_add_to_collection' : 'batch_actions'
      end

    end
  end
end
