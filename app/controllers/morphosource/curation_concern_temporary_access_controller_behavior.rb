module Morphosource
  # Include in controllers that want to use temporary access links
  module CurationConcernTemporaryAccessControllerBehavior
    extend ActiveSupport::Concern

    private

      def authorize_with_temporary_link_if_present(id)
        if temporary_link_cookie_exists? id
          current_ability.temporary_media_access_link = temporary_media_access_link_from_cookie(id)
        end
      end

      def temporary_link_cookie_exists?(id)
        cookies.encrypted[id].present? && 
        active_temporary_access_links.exists?(media_id: id, token: cookies.encrypted[id])
      end

      def temporary_media_access_link_from_cookie(id)
        active_temporary_access_links.find_by(media_id: id, token: cookies.encrypted[id])
      end

      def active_temporary_access_links
        TemporaryMediaAccessLink.active_links
      end
  end
end