# frozen_string_literal: true
module Morphosource
  class MediaThumbnailPathService < Hyrax::WorkThumbnailPathService
    class << self
      def default_image
        ActionController::Base.helpers.image_path 'work.png'
      end

      def call(object)
        return default_image unless object.try(:thumbnail_id)
        thumb = fetch_thumbnail(object)
        return unless thumb
        if thumbnail?(thumb)
          # add timestamp for fingerprinting
          if object.date_modified.present?
            timestamp = "&t=" + object.date_modified.to_time.to_i.to_s
          else
            timestamp = ""
          end
          thumbnail_path(thumb) + timestamp
        else
          default_image
        end
      end
    end
  end
end
