module Hyrax
  class CustomThumbnailsController < ApplicationController
    # POST /works/:id/custom_thumbnail
    def create
      # view uses: f.file_field :image
      params.require([:id,:image])
      authorize!(:edit, params[:id])
      work = Morphosource::Works::Base.find(params[:id])
      if Morphosource::MEDIA_FORMATS['Image'][:extensions].include? File.extname(params[:image].original_filename)
        thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(work.thumbnail_id,'thumbnail')
        original_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(work.thumbnail_id,'original_thumbnail')
        # Move an existing original 'thumbnail' to 'original_thumbnail',
        # but don't overwrite an 'original_thumbnail'
        if File.exist?(thumbnail_path)
          if !File.exist?(original_thumbnail_path)
            FileUtils.mv thumbnail_path, original_thumbnail_path
          else
            FileUtils.rm thumbnail_path
          end
        end
        FileUtils.mkdir_p(File.dirname(thumbnail_path))
        original_image = Tempfile.new(File.basename(work.thumbnail_id))
        begin
          original_image.binmode
          original_image.write(params[:image].read)
          Hydra::Derivatives::ImageDerivatives.create(original_image.path,
                                                      outputs: [{ label: :thumbnail,
                                                                  format: 'jpg',
                                                                  size: '200x150>',
                                                                  url: "file://#{thumbnail_path}",
                                                                  layer: 0 }])
        ensure
          original_image.close
          original_image.unlink
        end
        flash[:info] = "Custom thumbnail successfully updated."
      else
        flash[:error] = "Error setting custom thumbnail."
      end
      redirect_to my_works_path
    end

    # DELETE /works/:id/custom_thumbnail
    def destroy
      params.require(:id)
      authorize!(:edit, params[:id])
      work = Morphosource::Works::Base.find(params[:id])
      thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(work.thumbnail_id,'thumbnail')
      original_thumbnail_path = Hyrax::DerivativePath.derivative_path_for_reference(work.thumbnail_id,'original_thumbnail')
      if File.exist?(thumbnail_path)
        FileUtils.rm thumbnail_path
      end
      if File.exist?(original_thumbnail_path)
        FileUtils.mv original_thumbnail_path, thumbnail_path
      end
      flash[:info] = "Custom thumbnail successfully deleted."
      redirect_to my_works_path
    end
  end
end
