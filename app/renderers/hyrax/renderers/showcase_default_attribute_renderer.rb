module Hyrax
  module Renderers
    class ShowcaseDefaultAttributeRenderer < AttributeRenderer
      include ActionView::Context
      include ActionView::Helpers::NumberHelper
      include MorphosourceHelper
      
      def render
        markup = ''
        return markup if values_blank? && !options[:include_empty]
        css_classes = '' 
        if options[:css_classes]
          css_classes << options[:css_classes]
        end
        if options[:css_id]
          id_attribute = " id='#{options[:css_id]}'"
        else
          id_attribute = ''
        end
        value_per_line = options[:value_per_line].present? && options[:value_per_line] == true
        markup << %(<div class='row'>)

        label_width = options[:label_width].presence || 6
        value_width = options[:value_width].presence || 6

        label_content = options[:label].present? ? options[:label] : label
        hint_content  = options[:show_hint] ? hint : ""
        markup << %(<div class='col-xs-#{label_width} showcase-label'>#{label_content}#{hint_content}</div>)

        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        markup << %(<div#{id_attribute} class='col-xs-#{value_width} showcase-value #{css_classes}'>)
        if values_blank?
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
            if value_per_line
              markup << '<div>'
            else 
              markup << '; ' unless index == 0
            end
            markup << attribute_value_to_html(value.to_s)
            if value_per_line
              markup << '</div>'
            end
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

      def values_blank?
        values.blank? || (values.is_a?(Array) && values.all? { |x| x.blank? } )
      end

      def hint
        content_tag :i, class: ["material-icons", "tooltip-icon"] do
          content_tag :p, class: ["hint", "hide"] do
            translate(
              :"simple_form.hints.#{options[:work_type].downcase}.#{field}",
              default: [
                :"simple_form.hints.defaults.#{field}"
              ]
            )
          end
        end.html_safe
      end
    end
  end
end