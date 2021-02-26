module Hyrax
  module Renderers
    class ShowcaseAttachmentAttributeRenderer < ShowcaseDefaultAttributeRenderer
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
        if values.present?
          if options[:link_label].present?
            link_label = options[:link_label]
          else
            link_label = 'Attachment File'
          end
          markup << %(<span class='showcase-link'>#{link_to(link_label, values.first, target: :blank)}</span>)
        else
          if options[:text_if_empty].present?
            markup << options[:text_if_empty]
          else
            markup << %(--)
          end
        end
        markup << %(</div>)
        markup << %(</div>)
        markup.html_safe
      end
    end
  end
end