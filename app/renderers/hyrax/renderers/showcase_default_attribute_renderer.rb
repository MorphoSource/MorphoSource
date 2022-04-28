module Hyrax
  module Renderers
    class ShowcaseDefaultAttributeRenderer < AttributeRenderer
      include ActionView::Helpers::NumberHelper
      include MorphosourceHelper
      
      def render
        markup = ''
        return markup if values_blank? && !options[:include_empty]
        css_classes = '' 
        if options[:css_classes]
          css_classes << options[:css_classes]
        end
        markup << %(<div class='row'>)
        if options[:label].present?
          markup << %(<div class='col-xs-6 showcase-label'>#{options[:label]}</div>)
        else
          markup << %(<div class='col-xs-6 showcase-label'>#{label}</div>)
        end          
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        markup << %(<div class='col-xs-6 showcase-value #{css_classes}'>)
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
            markup << '; ' unless index == 0
            markup << attribute_value_to_html(value.to_s)
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

      def values_blank?
        values.blank? || (values.is_a?(Array) && values.all? { |x| x.blank? } )
      end
    end
  end
end