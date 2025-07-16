module Hyrax
  module Renderers
    class ShowcaseUserLinkAttributeRenderer < ShowcaseDefaultAttributeRenderer

      def user_link(user)
        markup = ''
        if user.is_a?(User)
          ms_id = user.ms_id
          display_text = user.name_or_email
          url = "/users/" + ms_id
        else
          id = user.id
          display_text = user.title.first
          url = "/organizations/" + id
        end
        link = link_to(display_text, "#{url}")
        link.html_safe
      end

      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank?

          user = ::User.find_by_user_key(value) || ::SolrDocument.where({"id" => value}).first
          if user.present?
            link = user_link(user)
          else
            markup
          end
        end
    end
  end
end
