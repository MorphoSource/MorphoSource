module Morphosource
  class IiifAuthorizationService < Hyrax::IiifAuthorizationService
    # override to auth with temp link credentials if present
    def can?(_action, object)
      if (
        !controller.current_ability.can?(:show, file_set_id_for(object)) &&
        controller.any_temporary_link_cookie_exists?
      ) 
        begin
          media_id = FileSet.find(file_set_id_for(object))&.member_of&.first&.id
          controller.authorize_media_with_temporary_link(media_id) if media_id.present?
        rescue ActiveFedora::ObjectNotFoundError
          return false
        end
      end

      super
    end
  end
end