module Hyrax
  module Renderers
    class ShowcaseAgreementUriFileAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def render
        markup = ''
        return markup if values.blank? && !options[:attachment_file_url].present? && !options[:include_empty]
        css_classes = '' 
        if options[:css_classes]
          css_classes << options[:css_classes]
        end
        markup << %(<div class='row'>)

        label_content = options[:label].present? ? options[:label] : label
        hint_content  = options[:show_hint] ? hint : ""
        markup << %(<div class='col-xs-6 showcase-label'>#{label_content}#{hint_content}</div>)

        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")
        markup << %(<div class='col-xs-6 showcase-value #{css_classes}'>)
        if options[:attachment_file_url].present?
          if options[:link_label].present?
            link_label = options[:link_label]
          else
            link_label = 'Agreement File'
          end
          markup << %(<span class='showcase-link'>#{link_to(link_label, options[:attachment_file_url]&.first, target: :_blank)}</span>)
        elsif values.blank?
          if options[:text_if_empty].present?
            markup << options[:text_if_empty]
          else
            markup << %(--)
          end
        else
          link_label = options[:link_label] || ''
          Array(values).each_with_index do |value, index|
            if options[:number_with_precision].present?
              value = number_with_precision(value, precision: options[:number_with_precision])
            end
            markup << '; ' unless index == 0
            markup << attribute_value_to_html(parse_url(value.to_s), link_label)
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end

      private

      def attribute_value_to_html(value, link_label)
        return '' if value.blank?
        link_label = value unless link_label.present?
        markup = "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link_to(link_label, value, target: :_blank)}</span>"
        markup.html_safe
      end

      def parse_url(url)
        u = URI.parse(url)
        if !u.scheme
          "http://#{url}"
        else
          url
        end
      end
    end
  end
end