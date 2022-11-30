module Morphosource
  module Collections
    class MediaListPresenter < Morphosource::CollectionPresenter

      def edit_path
        Rails.application.routes.url_helpers.media_list_edit_path(id, locale: I18n.locale)
      end

      def collection_type_title
        "Media List"
      end

      def membership(current_user)
        if collection.managers.include?(current_user)
          'Manager'
        elsif collection.viewers.include?(current_user)
          'Viewer'
        else
          ''
        end
      end
    end
  end
end
