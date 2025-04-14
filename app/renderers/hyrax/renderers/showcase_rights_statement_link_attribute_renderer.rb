module Hyrax
  module Renderers
    class ShowcaseRightsStatementLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
 
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
            link = %(<a href=#{ERB::Util.h(value)} target="_blank">#{Hyrax.config.rights_statement_service_class.new.label(value)}</a>)
            markup = "<i class='fa fa-external-link-alt'></i>&nbsp;<span class='showcase-link'>#{link}</span>"
            markup.html_safe
          end
        end
   end
  end
end