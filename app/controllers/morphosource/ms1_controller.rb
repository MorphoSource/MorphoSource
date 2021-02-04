module Morphosource
  class Ms1Controller < ApplicationController

    def biological_specimens
      redirect_to '/biological_specimens/' + pad(params[:id], 'S')
    end

    def media_group
      group_id = params[:id]
      media = Media.where('legacy_media_group_id' => group_id)&.first
      if media.present?
        redirect_to '/media/' + media.id
      else
        # todo: might consider return a custom error or redirect to 404 page
        redirect_to '/'
      end
    end

    def media
      redirect_to '/media/' + pad(params[:id], '')
    end

    def projects
      redirect_to '/projects/' + pad(params[:id], 'C')
    end

    private

      def pad(id, prefix)
        id = "#{prefix}#{id}"
        if id.length < 9
          id = ("0" * (9 - id.length)) + id
        else
          id
        end
      end

  end
end
