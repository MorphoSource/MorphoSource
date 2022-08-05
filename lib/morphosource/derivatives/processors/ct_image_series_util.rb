require 'fileutils'
require 'zip'

module Morphosource::Derivatives::Processors
  module CTImageSeriesUtil
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
      # get all image files and locations in zip
      img_locs = {}
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          next if File.basename(f.name).start_with?('.')
          ext = File.extname(f.name).downcase
          if acceptable_image_formats.include? ext
            loc = File.dirname(f.name)
            if !img_locs.key?(ext)
              img_locs[ext] = {}
            end
            if !img_locs[ext].key?(loc)
              img_locs[ext][loc] = []
            end
            img_locs[ext][loc] << f.name
          end
        end
      end

      # sort image collections by extension and location
      coll_by_ext = {}
      img_locs.each do |k, v|
        max = v.max_by { |sub_k, sub_v| sub_v.length }
        coll_by_ext[k] = max[1] if (max[1].length > 19 || k.downcase == '.dcm' || k.downcase == '.dicom')
      end

      # return largest group of most preferred file type
      acceptable_image_formats.each do |ext|
        if coll_by_ext.key?(ext)
          return coll_by_ext[ext], ext
        end
      end

      # case where acceptable image collection not found
      return [], nil
    end
  end
end