module Hyrax
  module Renderers
    class ShowcaseExternalLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          auto_link(value) do |link|
            "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
          end
        end
    end
  end
end