module Morphosource
  class Ms1Controller < ApplicationController

    def biological_specimens
      redirect_to '/biological_specimens/' + pad(params[:id], 'S')
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
