# Handles creation and deletion of temporary media access links
module Morphosource
  class TemporaryMediaAccessLinksController < ApplicationController
    load_and_authorize_resource only: :destroy
    
    def create
      params.require(:media_id)
      params.require(:expires_at)
      authorize! :edit, params[:media_id]

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
  end
end