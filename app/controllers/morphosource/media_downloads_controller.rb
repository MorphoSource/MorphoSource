module Morphosource
  class MediaDownloadsController < ApplicationController


    def show
      @keys = Array(params[:key])
    end

    private
      def media
        Media.where(accessControl_ssim: @keys)
      end

      def file_sets
        media.map(&:file_sets).flatten.compact
      end




  end
end