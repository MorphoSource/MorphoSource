module Hyrax
  module Renderers
    class ShowcaseCollectionLinkRenderer < ShowcaseDefaultAttributeRenderer

      def collection_link(collection)
        if collection.project?
          link = link_to(collection.title.first, Rails.application.routes.url_helpers.project_path(collection.id))
        elsif collection.team?
          link = link_to(collection.title.first, Rails.application.routes.url_helpers.team_path(collection.id))
        else
          link = ''
        end

        link.html_safe
      end

      # define method below if needed later
      #private
      #  def attribute_value_to_html(value)
      #    markup = ''
      #    return markup if value.blank?
      #    markup.html_safe
      #  end
    end
  end
end
