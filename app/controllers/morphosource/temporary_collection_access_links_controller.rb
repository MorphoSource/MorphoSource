# Handles creation and deletion of temporary collection access links
module Morphosource
  class TemporaryCollectionAccessLinksController < ApplicationController
    load_and_authorize_resource only: :destroy
    
    def create
      if !params[:collection_id].present?
        flash[:error] = "A project ID must be supplied when generating temporary project access link."
        redirect_to collection_edit_path(params[:collection_id]) and return
      end

      if !params[:expires_at].present?
        flash[:error] = "An expiration date must be supplied when generating temporary project access link."
        redirect_to collection_edit_path(params[:collection_id]) and return
      end

      authorize! :edit, params[:collection_id]

      temporary_link = TemporaryCollectionAccessLink.new(
        user: current_user,
        collection_id: params[:collection_id],
        expires_at: params[:expires_at]
      )

      if !temporary_link.valid?
        flash[:error] = "An unexpected error occurred when generating temporary collection access link."
        redirect_to collection_edit_path(params[:collection_id]) and return
      end

      temporary_link.save!

      flash[:info] = "Temporary collection access link generated."
      redirect_to collection_edit_path(params[:collection_id]) and return
    end

    def destroy
      collection_id = @temporary_collection_access_link.collection_id
      @temporary_collection_access_link.destroy
      redirect_to collection_edit_path(collection_id) and return
    end
  end
end