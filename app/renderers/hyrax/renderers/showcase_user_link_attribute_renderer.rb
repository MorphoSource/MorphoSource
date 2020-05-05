module Hyrax
  module Renderers
    class ShowcaseUserLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer

      def user_link(user)
        markup = ''
        ms_id = user.ms_id
        if user.display_name.present?
          display_text = user.display_name
        elsif user.email.present?
          display_text = user.email
        else
          display_text = ms_id
        end            
        url = "/users/" + ms_id
        link = link_to(display_text, "#{url}")
        link.html_safe
      end

      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank? 

          user = ::User.find_by_user_key(value)
          if user.present?
            link = user_link(user)
          else
            return markup
          end
          markup = "<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end