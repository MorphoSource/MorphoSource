module Morphosource
  class MediaListPresenter < Morphosource::CollectionPresenter

    def edit_path
      Rails.application.routes.url_helpers.edit_media_list_path(id, locale: I18n.locale)
    end
  end
end
