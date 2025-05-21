module Morphosource
  module Admin
    class PagesController < Morphosource::ItemtableController
      prepend_before_action :authorize_index, only: [:index]

      PAGE_TITLE = I18n.t("morphosource.admin.pages.page_title")
      
      def index
        super
      end

      private

      # Only admins can access this index route
      def authorize_index
        authorize! :manage, Page
      end

      def get_items
        @items = Page.all.order(sort_param)
      end

      def valid_sort_attributes
        ['page_type', 'title', 'created_at', 'updated_at', 'visibility']
      end

      def default_sort_param
        'created_at DESC'
      end
    end
  end
end