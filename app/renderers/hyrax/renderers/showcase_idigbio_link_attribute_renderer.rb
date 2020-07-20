module Hyrax
  module Renderers
    class ShowcaseIdigbioLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer

      def generated_link_from_bso(bso)
        label = ''
        if bso.idigbio_uuid.present?
          label = 'UUID'
        elsif bso.idigbio_recordset_id.present?
          label = 'recordset ID'
        end
        link_display_text = 'iDigbio'
        attribute_value_to_html(link_display_text)
      end

      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 
          # check field label to determine the idigbio url
          # todo: move the urls (and possibly the logic) outside of renderer, e.g presenter?
          label = '' unless label.present?
          if label.include? 'UUID'
            url = 'https://www.idigbio.org/portal/records/'
            link = link_to(value, "#{url}#{value}", target: :_blank)
          elsif label.include? 'recordset ID'
            url = 'https://www.idigbio.org/portal/recordsets/'
            link = link_to(value, "#{url}#{value}", target: :_blank)
          else
            url = 'https://www.idigbio.org'
            link = link_to(value, "#{url}", target: :_blank)
          end
          markup << "<span class='glyphicon glyphicon-new-window'></span>&nbsp;<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end