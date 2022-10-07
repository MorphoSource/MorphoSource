module Morphosource
    class TemporaryMediaLinksController < ApplicationController
  
      def generate_link
        params.require(:media_id, :expires_at)
        authorize! :generate_temporary_link, params[:media_id]
        # return authorize errors via JSON if possible

        temporary_link = TemporaryMediaLink.new(
          user: current_user,
          media: params[:media_id],
          expires_at: params[:expires_at]
        )
        # validate temporary_link using .valid? and .errors, return errors via JSON

        temporary_link.save!

        render :json => {
          status : "success",
          data : {
              "temporary_link" : { "token" : temporary_link.token }
           }
        }
      end

      def revoke_all_links
        # TODO
      end
    end
  end