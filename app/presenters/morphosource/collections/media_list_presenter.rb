module Morphosource
  module Collections
    class MediaListPresenter < Morphosource::CollectionPresenter

      def edit_path
        Rails.application.routes.url_helpers.media_list_edit_path(id, locale: I18n.locale)
      end

      def collection_type_title
        "Media List"
      end
    end
  end
end
