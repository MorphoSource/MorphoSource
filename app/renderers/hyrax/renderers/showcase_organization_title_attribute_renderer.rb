module Hyrax
  module Renderers
    class ShowcaseOrganizationTitleAttributeRenderer < ShowcaseDefaultAttributeRenderer

      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        css_classes = '' 
        if options[:css_classes]
          css_classes << options[:css_classes]
        end
        link = ''
        if options[:link] && options[:link].present?
          link = options[:link]
        end
        markup << %(<div class='row'>)
        markup << %(<div class='col-xs-6 showcase-label'>#{label}</div>)
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        markup << %(<div class='col-xs-6 showcase-value #{css_classes}'>)
        if values.blank?
          if options[:text_if_empty].present?
            markup << options[:text_if_empty]
          else
            markup << %(--)
          end
        else
          Array(values).each_with_index do |value, index|
            if is_number_with_decimal?(value)
              value = value.to_f.round(3)
            end
            markup << '; ' unless index == 0
            markup << attribute_value_to_html(value.to_s, link)
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

      private

        def attribute_value_to_html(value, link)
          markup = ''
          return markup if value.blank? 
          if link.present?
            markup << "<span class='showcase-link' style='word-break: normal;'>#{link_to(value, link)}</span>"
          else
            markup << "<span>#{value}</span>"
          end
          markup.html_safe
        end
    end
  end
end