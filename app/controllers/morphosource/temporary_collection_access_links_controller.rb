# Handles creation and deletion of temporary collection access links
module Morphosource
  class TemporaryCollectionAccessLinksController < ApplicationController
    load_and_authorize_resource only: :destroy
    
    def create
      params.require(:collection_id)
      params.require(:expires_at)
      authorize! :generate_temporary_link, params[:collection_id]

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

    def destroy_all
      params.require(:collection_id)
      if current_user && (links = current_user.temporary_collection_access_links.where(collection_id: params[:collection_id])).present?
        links.each do |link|
          authorize! :destroy, link
          link.destroy
        end
      end
      redirect_to collection_edit_path(params[:collection_id]) and return
    end
  end
end