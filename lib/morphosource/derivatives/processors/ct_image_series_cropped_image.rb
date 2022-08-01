require 'fileutils'
require 'zip'

module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  # Processor to create a single 2D image thumbnail from 
  class CTImageSeriesCroppedImage < Morphosource::Derivatives::Processors::CroppedImage
    include Morphosource::Derivatives::Processors::CTImageSeriesUtil

    attr_accessor :img_coll

    class_attribute :timeout

    def process
      timeout ? process_with_timeout : create_ct_image_series_cropped_image_derivative
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_ct_image_series_cropped_image_derivative }
    rescue Timeout::Error
      raise Morphosource::Derivatives::Processors::TimeoutError, "Unable to process CT Image Series derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    protected
    
    def create_ct_image_series_cropped_image_derivative
      locate_images
      return unless img_coll.present?
      get_image_for_thumbnail # selects image and loads it to @source_path
      create_resized_image
    end

    def get_image_for_thumbnail
      Zip::File.open(source_path) do |zip_file|
        @source_path = zip_file.get_input_stream(img_coll[img_coll.count/2])
      end
    end
  end
end