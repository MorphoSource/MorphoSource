module Hyrax
  module Renderers
    class ShowcaseUserLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          # url example: /users/johndoe@gmail-dot-com
          url = "/users/" + value.gsub(/(.+)@([^.]+)\.(.+)/, '\1@\2-dot-\3')
          link = link_to(value, "#{url}")
          markup = "<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end