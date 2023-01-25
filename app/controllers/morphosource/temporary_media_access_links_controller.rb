module Morphosource
  class TemporaryMediaAccessLinksController < ApplicationController
    load_and_authorize_resource only: :destroy

    def create
      params.require(:media_id)
      params.require(:expires_at)
      authorize! :generate_temporary_link, params[:media_id]
      # return authorize errors via JSON if possible

      temporary_link = TemporaryMediaAccessLink.new(
        user: current_user,
        media_id: params[:media_id],
        expires_at: params[:expires_at]
      )

      if !temporary_link.valid?
        flash[:error] = "An unexpected error occurred when generating temporary media access link."
        redirect_to media_showcase_edit_path(params[:media_id], anchor: 'share') and return
      end

      temporary_link.save!

      flash[:info] = "Temporary media access link generated."
      redirect_to media_showcase_edit_path(params[:media_id], anchor: 'share') and return
    end

    def destroy
      media_id = @temporary_media_access_link.media_id
      @temporary_media_access_link.destroy
      redirect_to media_showcase_edit_path(media_id, anchor: 'share') and return
    end

    def destroy_all
      params.require(:media_id)
      if current_user && (links = current_user.temporary_media_access_links.where(media_id: params.require(:media_id))).present?
        links.each do |link|
          authorize! :destroy, link
          link.destroy
        end
      end
      redirect_to media_showcase_edit_path(params[:media_id], anchor: 'share') and return
    end
  end
end