module Hyrax
  module Renderers
    class ShowcaseIdigbioLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer
      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          # check field label to determine the idigbio url
          # todo: move the urls (and possibly the logic) outside of renderer, e.g presenter?
          if label.include? 'UUID'
            url = 'https://www.idigbio.org/portal/records/'
          elsif label.include? 'recordset ID'
            url = 'https://www.idigbio.org/portal/recordsets/'
          else
            url = 'https://www.idigbio.org'
          end
          link = link_to(value, "#{url}#{value}")
          markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end