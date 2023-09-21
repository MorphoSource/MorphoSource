module Hyrax
  module Renderers
    class ShowcaseSimpleLinkAttributeRenderer < ShowcaseSimpleAttributeRenderer

      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]

        link = ''
        if options[:link] && options[:link].present?
          link = options[:link]
        end

        if values.blank?
          if options[:text_if_empty].present?
            markup << options[:text_if_empty]
          else
            markup << %(--)
          end
        else
          Array(values).each_with_index do |value, index|
            if options[:number_with_precision].present?
              value = number_with_precision(value, precision: options[:number_with_precision])
            end
            markup << '; ' unless index == 0
            markup << attribute_value_to_html(value.to_s, link)
          end
        end
        markup.html_safe
      end

      private

        def attribute_value_to_html(value, link)
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