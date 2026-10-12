module Morphosource
  module CustomThumbnails

    # called from submissions #create and media #update
    def create_thumbnail
      return unless custom_thumbnail.present?

      return unless thumbnail_format_valid?

      make_derivative_directory
      create_derivative
      update_thumbnail_id
      sync_media_derivative_size
    end

    # called from media #update
    def delete_thumbnail
      # delete custom thumbnail if it exists
      if File.exist?(thumbnail_path(media))
        FileUtils.rm thumbnail_path(media)
      end
      # set file set derivative as thumbnail
      if File.exist?(thumbnail_path(file_set))
        media.thumbnail_id = file_set.id
      else
        media.thumbnail_id = nil
      end
      media.save
      sync_media_derivative_size
    end

    def custom_thumbnail
      @custom_thumbnail ||= params[:media][:custom_thumbnail]
    end

    # media == new_media if new submission
    # media == @curation_concern if media#update
    def media
      @media ||= (new_media || @curation_concern)
    end

    def new_media
      return unless @submission
      Media.find(@submission.media_id)
    end

    def file_set
      media.file_sets.first
    end

    def thumbnail_format_valid?
      Morphosource::MEDIA_FORMATS['Image'][:extensions].include? File.extname(custom_thumbnail.original_filename).downcase
    end

    def make_derivative_directory
      FileUtils.mkdir_p(File.dirname(thumbnail_path(media)))
    end

    def create_derivative
      begin
        ::Morphosource::Derivatives::CroppedImageDerivatives.create(
          custom_thumbnail.path,
          outputs: [{
            label: :thumbnail,
            url: thumbnail_url,
          }]
        )
      ensure
        unless @preview_file.present? # no need to remove temp file for batch submission
          if custom_thumbnail.respond_to?(:tempfile)
            custom_thumbnail.tempfile.close
            custom_thumbnail.tempfile.unlink
          end
        end
      end
    end

    def update_thumbnail_id
      # get new work since this can hit race condition on work creation
      media_to_be_saved = Media.find(media.id)
      media_to_be_saved.thumbnail = media_to_be_saved
      media_to_be_saved.save
    end

    def thumbnail_path(work)
      Hyrax::DerivativePath.derivative_path_for_reference(work, 'thumbnail')
    end

    def thumbnail_url
      "file://#{thumbnail_path(media)}"
    end

    private

    # Re-globs media-level derivative files after each create/delete and persists
    # the total in FileSetSizeInfo so sum_file_size stays accurate without disk
    # reads at index or charge time.
    def sync_media_derivative_size
      size = Morphosource::DerivativePath.derivatives_for_reference(media.id)
               .map { |p| File.size?(p) }.compact.sum
      FileSetSizeInfo.update_media_derivatives(media.id, size)
    rescue => e
      Rails.logger.error "FileSetSizeInfo media derivative sync failed for #{media&.id}: #{e.message}"
    end
  end
end
