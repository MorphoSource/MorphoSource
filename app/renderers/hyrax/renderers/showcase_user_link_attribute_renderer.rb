module Hyrax
  module Renderers
    class ShowcaseUserLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer

      def user_link(user)
        markup = ''
        case user
        when User
          ms_id = user.ms_id
          display_text = user.name_or_email
          url = "/users/" + ms_id
        when OrganizationCollection
          id = user.id
          display_text = user.name
          url = "/organizations/" + id
        end
        link = link_to(display_text, "#{url}")
        link.html_safe
      end

      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank?

          user = ::User.find_by_user_key(value) || OrganizationCollection.find_by(id: value)
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
