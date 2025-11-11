module Morphosource
  module Collections
    class MediaListPresenter < Morphosource::CollectionPresenter

      delegate :list_type, :doi, to: :solr_document

      def doi_badge
        return '' if doi.nil? || doi.empty?
        content_tag(:span, "DOI: #{doi.first}", class: "badge badge-info")
      end

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

      # Returns the display name of the creator, whether a User or OrganizationCollection
      # Used in collection counts partial
      def creator_display
        User.find_by(ms_id: creator&.first)&.display_name ||
        SolrDocument.find(creator&.first)['title_tesim']&.first ||
        ''
      rescue
        ''
      end
    end
  end
end
