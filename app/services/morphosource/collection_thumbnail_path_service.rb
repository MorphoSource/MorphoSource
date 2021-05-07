# frozen_string_literal: true

module Morphosource
  class CollectionThumbnailPathService < Hyrax::CollectionThumbnailPathService
    class << self
      def default_image
        ActionController::Base.helpers.image_path 'collection.png'
      end

      def call(object)
        return default_image unless object.try(:thumbnail_id)
        thumb = fetch_thumbnail(object)
        return default_image unless thumb
        if thumbnail?(thumb)
          thumbnail_path(thumb)
        else
          default_image
        end
      end
    end
  end
end
