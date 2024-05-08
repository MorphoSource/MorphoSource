module Hyrax
  module Renderers
    class ShowcaseOrganizationLinksAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          return markup unless ActiveFedora::Base.exists?(value)

          org = ActiveFedora::Base.find(value)
          label = org.title.first
          if org.class == Organization
            link = Rails.application.routes.url_helpers.hyrax_organization_path(value)
          elsif org.class == OrganizationCollection
            link = Rails.application.routes.url_helpers.organization_collection_path(value)
          else
            return markup
          end
          markup << "<span class='showcase-link' style='word-break: normal;'>#{link_to(label, link)}</span>"
          markup.html_safe
        end
    end
  end
end