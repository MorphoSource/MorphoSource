# Display remote file health for admin
module Morphosource
  module Admin
    class RemoteFileHealthsController < Morphosource::ItemtableController
      prepend_before_action :authorize_index, only: [:index]

      PAGE_TITLE = I18n.t("morphosource.admin.remote_file_health.page_title")
      PAGE_DESCRIPTION = I18n.t("morphosource.admin.remote_file_health.page_description")

      def index
        if RemoteFileHealth.count > 0
          @last_checked =  RemoteFileHealth.last.created_at.strftime("%A, %B %d, %Y at %I:%M %p")
        else
          @last_checked = "(none)"
        end
        super
      end
      
      private

      # Only admins can access this index route
      def authorize_index
        authorize! :manage, RemoteFileHealth
      end

      def get_items
        @items = RemoteFileHealth.where(status:'Problematic').order(sort_param)
      end

      def valid_sort_attributes
        ['media', 'status']
      end

      def default_sort_param
        'media ASC'
      end

      def valid_filter_attributes
        ['media', 'status']
      end

      def prepare_items_for_csv
        @items = @items.map do |item|
          item.attributes.map do |field, value|
            if field == 'created_at'
              field = 'last_system_checked'
            end
  
            if value.kind_of? Array
              value = value.join(';')
            end
  
            [field, value]
          end.to_h
        end
      end
 
    end
  end
end