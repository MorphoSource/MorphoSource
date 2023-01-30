# Handles viewing of media through temporary access link
module Hyrax
  class MediaTemporaryLinkViewController < MediaController
    before_action :load_temporary_media_access_link,
      :authorize_temporary_media_access_link,
      :load_curation_concern_resource,
      :authorize_curation_concern_resource,
      :set_authorization_cookie, only: :showcase
    skip_authorize_resource only: [:showcase, :thumbnail]

    # Want to make use of hyrax/media views
    def self.controller_path
      "hyrax/media"
    end

    def showcase
      @presenter = show_presenter.new(@curation_concern_from_search_result, current_ability, request)
      @presenter.get_showcase_data
      render '/hyrax/media/showcase', presenter: @presenter
    end

    private

      def search_builder_class
        Morphosource::TemporaryMediaAccessLinkSearchBuilder
      end

      def load_temporary_media_access_link
        params.require(:id)
        params.require(:token)
        @temporary_media_access_link = TemporaryMediaAccessLink.find_by(media_id: params[:id], token: params[:token])
      end

      def authorize_temporary_media_access_link
        raise CanCan::AccessDenied.new(nil, :show) unless (@temporary_media_access_link.present? && @temporary_media_access_link.active?)
      end

      def load_curation_concern_resource
        _, document_list = search_results(id: @temporary_media_access_link.media_id)
        raise CanCan::AccessDenied.new(nil, :show) if document_list.empty?
        @curation_concern_from_search_result = document_list.first
      end

      def authorize_curation_concern_resource
        current_ability.temporary_media_access_link = @temporary_media_access_link
        current_ability.authorize! :read, @curation_concern_from_search_result
      end

      def set_authorization_cookie
        return if cookies.encrypted[@curation_concern_from_search_result.id].present?

        cookies.encrypted[@curation_concern_from_search_result.id] = { 
          value: @temporary_media_access_link.token, 
          expires: @temporary_media_access_link.expires_at
        }
      end
  end
end