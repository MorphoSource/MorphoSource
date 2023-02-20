module Hyrax
  module Renderers
    class ShowcaseExternalLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank?
          link = link_to(value, format_url(value), target: :blank)
          markup = "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end

        def format_url(value)
          unless value[/\Ahttp:\/\//] || value[/\Ahttps:\/\//]
            "http://#{value}"
          else
            value
          end
        end
    end
  end
end