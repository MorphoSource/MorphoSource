module Hyrax
  module Renderers
    # Will render default field value with arbitrary HTML block underneath (e.g., a "more info" modal content)
    # Takes content param with HTML block value in addition to standard renderer params
    class ShowcaseValueAndContentAttributeRenderer < ShowcaseDefaultAttributeRenderer

      private

      def attribute_value_to_html(value)
        markup = ''
        return markup if value.blank? 
        if options[:content].present?
          markup << "<div><span>#{value}</span></div><div>#{options[:content].html_safe}</div>"
        else
          markup << "<span>#{value}</span>"
        end
        markup.html_safe
      end
    end
  end
end