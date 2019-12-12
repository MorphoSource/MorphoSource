
module Hyrax
  module Renderers
    class ShowcaseDefaultAttributeRenderer < AttributeRenderer
      include MorphosourceHelper
      
      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        css_classes = '' 
        if options[:css_classes]
          css_classes << options[:css_classes]
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
          Array(values).each do |value|
            if is_number_with_decimal?(value)
              value = value.to_f.round(3)
            end
            markup << attribute_value_to_html(value.to_s)
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

    end
  end
end