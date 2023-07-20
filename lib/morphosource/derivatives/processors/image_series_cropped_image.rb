require 'fileutils'
require 'zip'
require 'archive/tar/minitar'

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
      case File.extname(source_path).downcase
      when '.zip'
        Zip::File.open(source_path) do |zip_file|
          zip_file.extract(img, img_path)
        end
      when '.tar'
        File.open(source_path, 'rb') do |file|
          Archive::Tar::Minitar::Reader.open(file) do |tar|
            tar.each_entry do |entry|
              if entry.name == img
                File.new(img_path, 'wb')
                File.open(img_path, 'wb') do |output_file|
                  output_file.write(entry.read)
                end
                break
              end
            end
          end
        end
      else
        raise "Archive file extension not valid"
      end
      @source_path = img_path
    end

    def convert_dicom_image
      new_img_path = File.join(tmp_dir_path, 'converted_dicom.png')
      dcmj2pnm = Morphosource::Derivatives::Dcmj2pnm.new(source_path, new_img_path)
      dcmj2pnm.call
      @source_path = new_img_path
    end

    def cleanup_tmp_files
      FileUtils.rm_r tmp_dir_path
    end
  end
end