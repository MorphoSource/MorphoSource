module Hyrax
  module Renderers
    class ShowcaseLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

      def attribute_value_to_html(value)
        link = ''
        if options[:link] && options[:link].present?
          link = options[:link]
        end

        markup = ''
        return markup if value.blank? 
        if link.present?
          markup << "<span class='showcase-link'>#{link_to(value, link)}</span>"
        else
          markup << "<span>#{value}</span>"
        end
        markup.html_safe
      end
    end
  end
end