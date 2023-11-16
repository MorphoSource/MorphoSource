module Morphosource
  module Collections
    class OrganizationPresenter < Morphosource::CollectionPresenter

      def edit_path
        Rails.application.routes.url_helpers.organization_edit_path(id, locale: I18n.locale)
      end

      def collection_type_title
        "Organization"
      end

      def organization
        @collection
      end

    end
  end
end