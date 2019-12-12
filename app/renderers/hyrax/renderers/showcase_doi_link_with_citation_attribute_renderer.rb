module Hyrax
  module Renderers
    class ShowcaseDoiLinkWithCitationAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        markup << %(<div class='row'>)
        markup << %(<div class='col-xs-6 showcase-label'>)
        if values.blank?
          markup << %(--)
        else
          Array(values).each do |value|
            markup << attribute_value_to_html(value.to_s)
          end
        end
        markup << %(</div>)
        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        markup << %(<div class='col-xs-6 showcase-value'>)
        # todo: auto-populated citation text information on the right, e.g.: https://crosscite.org/docs.html
        markup << %(Not yet implemented)
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          # todo: move the urls (and possibly the logic) outside of renderer, e.g presenter?
          url = 'https://doi.org/'
          link = link_to(value, "#{url}#{value.gsub(/^doi\:/, '')}")
          markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end