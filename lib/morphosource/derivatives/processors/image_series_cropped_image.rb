require 'fileutils'

module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  # Processor to create a single 2D image thumbnail from 
  class ImageSeriesCroppedImage < Morphosource::Derivatives::Processors::CroppedImage
    include Morphosource::Derivatives::Processors::ImageSeriesUtil

    attr_accessor :tmp_dir_path, :img_coll, :ext

    class_attribute :timeout

    def process
      timeout ? process_with_timeout : create_image_series_cropped_image_derivative
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_image_series_cropped_image_derivative }
    rescue Timeout::Error
      raise Morphosource::Derivatives::Processors::TimeoutError, "Unable to process Image Series derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    protected
    
    def create_image_series_cropped_image_derivative
      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      begin
        @img_coll, @ext = locate_images
        return unless img_coll.present?
        extract_image_for_thumbnail
        convert_dicom_image if dicom_image_formats.include?(ext)
        create_resized_image
      rescue StandardError => e
        cleanup_tmp_files
        raise e
      end
      cleanup_tmp_files
    end

    def extract_image_for_thumbnail
      img = img_coll[img_coll.count/2]
      img_path = File.join(tmp_dir_path, File.basename(img))

      Morphosource::Files::ArchiveService.new(source_path).extract_archive(
        tmp_dir_path,
        [img],
        false
      )

      if File.exists?(img_path)
        @source_path = img_path
      else
        raise "Thumbnail target file (#{img}) not found in archive when extracting files"
      end
    end

    def convert_dicom_image
      new_img_path = File.join(tmp_dir_path, 'converted_dicom.png')
      dcmj2pnm = Morphosource::Derivatives::Dcmj2pnm.new(source_path, new_img_path)
      dcmj2pnm.call
      @source_path = new_img_path
    end

    def cleanup_tmp_files
      begin
        FileUtils.rm_r tmp_dir_path
      rescue Errno::ENOTEMPTY
        Rails.logger.debug "in cleanup_tmp_files: Directory '#{tmp_dir_path}' not empty."
      end
    end
  
  end
end