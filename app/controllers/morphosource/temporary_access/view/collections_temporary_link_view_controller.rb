# Handles viewing of collection through temporary access link
# TODO: All of this!
module Hyrax
  class CollectionsTemporaryLinkViewController < ApplicationController
    before_action :load_temporary_collection_access_link,
      :authorize_temporary_collection_access_link,
      :load_collection,
      :authorize_collection,
      :set_authorization_cookie, only: :show

    def show
      flash[:notice] = I18n.t 'morphosource.media.view.temporary_access'
      redirect_to main_app.collection_path(params[:collection_id])
    end

    private
      def load_temporary_collection_access_link
        params.require(:id)
        params.require(:token)
        @temporary_collection_access_link = TemporaryCollectionAccessLink.find_by(collection_id: params[:id], token: params[:token])
      end

      def authorize_temporary_collection_access_link
        raise CanCan::AccessDenied.new(nil, :show) unless (@temporary_collection_access_link.present? && @temporary_collection_access_link.active?)
      end

      def load_collection
        @collection = SolrDocument.find(params[:id])
      end

      def authorize_collection
        current_ability.temporary_collection_access_link = @temporary_collection_access_link
        current_ability.authorize! :read, @collection
      end

      def set_authorization_cookie
        return if cookies.encrypted[@collection.id].present?

        cookies.encrypted[@collection.id] = { 
          value: @temporary_collection_access_link.token, 
          expires: @temporary_collection_access_link.expires_at
        }
      end
  end
end