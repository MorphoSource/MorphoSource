# frozen_string_literal: true

module Morphosource
  # Service for creating and deleting custom thumbnails for a Media object.
  class MediaCustomThumbnailService
    include Hyrax::Lockable
    include Morphosource::CustomThumbnails

    attr_reader :media, :custom_thumbnail

    # @param media [Media] the media object to modify
    # @param custom_thumbnail [ActionDispatch::Http::UploadedFile] the uploaded thumbnail file
    def initialize(media:, custom_thumbnail: nil)
      @media = media
      @custom_thumbnail = custom_thumbnail
    end

    # Creates a custom thumbnail for the media object.
    # @return [Media] the saved media object
    def create_thumbnail
      acquire_lock_for(media.id) do
        media.reload
        super
        media
      end
    end

    # Deletes the custom thumbnail for the media object.
    def delete_thumbnail
      acquire_lock_for(media.id) do
        media.reload
        super
      end
    end
  end
end