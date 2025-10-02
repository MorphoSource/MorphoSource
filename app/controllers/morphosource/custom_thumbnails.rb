module Morphosource
  module CustomThumbnails

    # called from submissions #create and media #update
    def create_thumbnail
      Rails.logger.info "[in CustomThumbnails] media's representative_id #{media.representative_id}, thumbnail_id #{media.thumbnail_id},  ordered_members #{media.ordered_members&.to_a.map(&:id)}"
      return unless custom_thumbnail.present?

      return unless thumbnail_format_valid?

      make_derivative_directory
      create_derivative
      update_thumbnail_id
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
          custom_thumbnail.tempfile.close
          custom_thumbnail.tempfile.unlink
        end
      end
    end

    def update_thumbnail_id
      media.thumbnail_id = media.id
      media.save
      Rails.logger.info "[in CustomThumbnails] media's representative_id #{media.representative_id}, thumbnail_id #{media.thumbnail_id},  ordered_members #{media.ordered_members&.to_a.map(&:id)}"
    end

    def thumbnail_path(work)
      Hyrax::DerivativePath.derivative_path_for_reference(work, 'thumbnail')
    end

    def thumbnail_url
      "file://#{thumbnail_path(media)}"
    end
  end
end
