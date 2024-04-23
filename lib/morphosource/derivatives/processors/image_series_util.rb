require 'fileutils'
require 'zip'

module Morphosource::Derivatives::Processors
  module ImageSeriesUtil
    def dicom_image_formats
      ['.dcm', '.dicom', '.ima', '']
    end

    def acceptable_image_formats
      dicom_image_formats + ['.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg']
    end

    def derivatives_tmp_path
      Hyrax.config.derivatives_tmp_path
    end

    def locate_images
      Morphosource::Files::ArchiveService.new(source_path)
        .largest_file_group(
          acceptable_image_formats, 
          cutoff: 20, 
          cutoff_exception_exts: ['.dcm', '.dicom']
        )
    end
  end
end