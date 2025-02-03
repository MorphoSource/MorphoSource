module Morphosource
  module Breadcrumbs
    module Collections
      extend ActiveSupport::Concern
      include Morphosource::Breadcrumbs

      included do
        before_action :build_breadcrumbs, only: [:index, :edit, :members, :projects, :organization, :permissions, :ownership]
      end

      private

      # Dashboard collections index page
      # # Ex: Home / Dashboard / Media Lists
      # Dashboard collection edit pages
      # # Ex: Home / Dashboard / Edit Project / Details
      def add_breadcrumb_for_action
        if action_name == 'index'
          add_breadcrumb t(:"morphosource.dashboard.my.collections.#{collections_type}.page_title"), '', mark_active_action
        else
          add_breadcrumb t(:'morphosource.dashboard.collections.edit.header', type_title: collection_type.title), send("#{collection_type.machine_id}_edit_path", params["id"])
          add_breadcrumb t(:"morphosource.dashboard.collections.#{controller_name.singularize}.#{action_name}.title"), '', mark_active_action
        end
      end
    end
  end
end
