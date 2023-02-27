module Morphosource
  module Collections
    module MediaLists
      class SequentialSectionListPresenter < Morphosource::Collections::MediaListPresenter

        def edit_path
          Rails.application.routes.url_helpers.sequential_section_list_edit_path(id, locale: I18n.locale)
        end

        def collection_type_title
          "Sequential Section List"
        end

      end
    end
  end
end
