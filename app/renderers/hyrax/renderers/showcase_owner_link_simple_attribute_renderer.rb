# Use this instead of ShowcaseUserLinkSimpleAttributeRenderer when value can be a user or an organization
module Hyrax
  module Renderers
    class ShowcaseOwnerLinkSimpleAttributeRenderer < ShowcaseSimpleAttributeRenderer

      def owner_link(owner)
        markup = ''
        if owner.is_a?(::User)
          display_text = owner.name_or_email
          url = "/users/" + owner.ms_id
        else
          display_text = owner.title.first
          url = "/organizations/" + owner.id
        end
        link = link_to(display_text, "#{url}")
        link.html_safe
      end

      private

        def attribute_value_to_html(value)
          markup = ''
          return markup if value.blank?

          owner = ::User.find_by_user_key(value) || OrganizationCollection.find_by(id: value)
          if owner.present?
            link = owner_link(owner)
          else
            return markup
          end
          markup = "<span class='showcase-link'>#{link}</span>"
          markup.html_safe
        end
    end
  end
end