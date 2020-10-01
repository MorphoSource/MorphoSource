module Hyrax
  module Renderers
    class ShowcaseIdigbioLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer

      def render
        markup = ''
        return markup if values.blank? && !options[:include_empty]
        css_classes = '' 
        if options[:css_classes]
          css_classes << options[:css_classes]
        end
        link = ''
        if options[:link]
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

      def generated_link_from_bso(bso)
        value = ''
        link = ''
        if bso.idigbio_uuid&.first.present?
          value = 'iDigBio'
          link = "https://www.idigbio.org/portal/records/#{bso.idigbio_uuid&.first}"
        else 
          value = 'User Created'
        end
          
        attribute_value_to_html(value, link)
      end

      private

        def attribute_value_to_html(value, link)
          markup = ''
          return markup if value.blank? 
          # if url, show idigbio link
          if link.present? && link =~ URI.regexp(['http', 'https'])
            markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link_to(value, link, target: :_blank)}</span>"
          else
            markup << "<span>#{value}</span>"
          end
          markup.html_safe
        end
    end
  end
end