module Hyrax
  module Renderers
    class ShowcasePageLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          return markup unless ActiveFedora::Base.exists?(value)

          obj = ActiveFedora::Base.find(value)
          case obj
          when Organization
            label = obj.title.first
            link = Rails.application.routes.url_helpers.hyrax_organization_path(value)
          when OrganizationCollection
            label = obj.title.first
            link = Rails.application.routes.url_helpers.organization_collection_path(value)
          when Device
            label = obj.creator.first
            link = Rails.application.routes.url_helpers.hyrax_device_path(value)
          when Media
            label = obj.title.first
            link = Rails.application.routes.url_helpers.hyrax_media_path(value)
          when BiologicalSpecimen
            label = obj.title.first
            link = Rails.application.routes.url_helpers.hyrax_biological_specimen_path(value)
          when CulturalHeritageObject
            label = obj.title.first
            link = Rails.application.routes.url_helpers.hyrax_cultural_heritage_object_path(value)
          else
            return markup
          end
          markup << "<span class='showcase-link' style='word-break: normal;'>#{link_to(label, link)}</span>"
          markup.html_safe
        end
    end
  end
end