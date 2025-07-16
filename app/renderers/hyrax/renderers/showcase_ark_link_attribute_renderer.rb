module Hyrax
  module Renderers
    class ShowcaseArkLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          return '' if value.blank? 
          return "<i class='fas fa-external-link-alt'></i>&nbsp;<span class='showcase-link'>#{ark_link(value)}</span>".html_safe
        end
    end
  end
end