module Hyrax
  module Renderers
    class ShowcaseLicenseLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
 
      private

        def attribute_value_to_html(value)
          begin
            parsed_uri = URI.parse(value)
          rescue URI::InvalidURIError
            nil
          end
          if parsed_uri.nil?
            ERB::Util.h(value)
          else
            link = %(<a href=#{ERB::Util.h(value)} target="_blank">#{Hyrax.config.license_service_class.new.label(value)}</a>)
            markup = "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
            markup.html_safe
          end
        end
   end
  end
end