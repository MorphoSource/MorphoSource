# frozen_string_literal: true
module Morphosource
  class MediaThumbnailPathService < Hyrax::WorkThumbnailPathService
    class << self
      def default_image
        ActionController::Base.helpers.image_path 'work.png'
      end

      def call(object)
        return external_thumbnail if object.import_url
        return default_image unless object.try(:thumbnail_id)
        thumb = fetch_thumbnail(object)
        return unless thumb
        if thumbnail?(thumb)
          thumbnail_path(thumb)
        else
          default_image
        end
      end

      def external_thumbnail
        if object.thumbnail_id&.first
          object.thumbnail_id.first
        else
          default_image
        end
      end
    end
  end
end
