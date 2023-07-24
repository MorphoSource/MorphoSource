require 'fileutils'
require 'zip'

module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  class CTImageSeries < Hydra::Derivatives::Processors::Processor
    include Morphosource::Derivatives::Processors::ImageSeriesUtil

    attr_accessor :tmp_dir_path, :img_coll, :ext
    attr_accessor :input_path, :scaled_path, :raw_dcm_path, :output_path, :manifest_path
    attr_accessor :raw_dcm_file_path, :output_file_path
    attr_accessor :x, :y, :z, :linear_scale_factor
    attr_accessor :slice_thickness, :unit, :x_spacing, :y_spacing, :z_spacing

    class_attribute :timeout

    def process
      timeout ? process_with_timeout : create_ct_image_series_derivative
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_ct_image_series_derivative }
    rescue Timeout::Error
      raise Morphosource::Derivatives::Processors::TimeoutError, "Unable to process CT Image Series derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    protected

    def create_ct_image_series_derivative
      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      @input_path = File.join(tmp_dir_path, 'input')
      Dir.mkdir input_path unless File.exist? input_path
      @scaled_path = File.join(tmp_dir_path, 'scaled')
      Dir.mkdir scaled_path unless File.exist? scaled_path
      @raw_dcm_path = File.join(tmp_dir_path, 'raw_dcm')
      Dir.mkdir raw_dcm_path unless File.exist? raw_dcm_path
      @raw_dcm_file_path = File.join(raw_dcm_path, 'derivative.dcm')
      @output_path = File.join(tmp_dir_path, 'output')
      Dir.mkdir output_path unless File.exist? output_path
      @output_file_path = File.join(output_path, 'derivative.dcm')

      @x_spacing = (directives.fetch(:x_spacing, 1).presence || 1).to_f
      @y_spacing = (directives.fetch(:y_spacing, 1).presence || 1).to_f
      @z_spacing = (directives.fetch(:z_spacing, 0).presence || 0).to_f
      @slice_thickness = (directives.fetch(:slice_thickness, 0).presence || 0).to_f
      if z_spacing == 0 && slice_thickness == 0
        puts('first if hit')
        if x_spacing && y_spacing
          puts('second if')
          @z_spacing = x_spacing
        else
          @z_spacing = 1
        end
      end
      # @z_spacing = 1 if z_spacing == 0 && slice_thickness == 0

      # If unit is not Mm, must convert spacing values to Mm
      @unit = directives.fetch(:unit, 'Mm').presence || 'Mm'
      correct_spacing_scale if unit != 'Mm'

      begin
        @img_coll, @ext = locate_images
        return unless img_coll.present?
        # extract and process images
        extract_images
        uncompress_dcm if dicom_image_formats.include?(ext)
        extract_image_metadata
        scale_images
        tif_to_raw_dcm
        compress_dcm
        # place files
        write_files
      rescue StandardError => e
        cleanup_tmp_files
        raise e
      end
      cleanup_tmp_files
    end

    def correct_spacing_scale
      unit_factors = { 'Cm' => 10.0, 'M' => 1000.0, 'Km' => 1e6, 'In' => 25.4, 'Ft' => 304.8, 'Mi' => 1.609e+6, 'Um' => 0.001 }
      uf = unit_factors[unit]

      @x_spacing*= uf
      @y_spacing*= uf
      @z_spacing*= uf
      @slice_thickness*= uf
    end

    def extract_images
      case File.extname(source_path).downcase
      when '.zip'
        Zip::File.open(source_path) do |zip_file|
          img_coll.each do |f|
            f_path = File.join(input_path, File.basename(f))
            zip_file.extract(f, f_path)
          end
        end
      when '.tar'
        File.open(source_path, 'rb') do |file|
          Archive::Tar::Minitar::Reader.open(file) do |tar|
            tar.each_entry do |entry|
              if img_coll.include? entry.name
                f_path = File.join(input_path, File.basename(entry.name))
                File.new(f_path, 'wb')
                File.open(f_path, 'wb') do |output_file|
                  output_file.write(entry.read)
                end
              end
            end
          end
        end
      else
        raise "Archive file extension not valid"
      end
    end

    def uncompress_dcm
      dcmdjpeg = Morphosource::Derivatives::Dcmdjpeg.new(input_path, input_path)
      dcmdjpeg.call
    end

    def extract_image_metadata
      files = {}
      z = 0
      Dir.foreach(input_path) do |f|
        next if f == '.' or f == '..'
        x_dim, y_dim = image_dims(File.join(input_path, File.basename(f)))
        if x_dim.present? && y_dim.present?
          dim_object = { x: x_dim, y: y_dim }
          files[dim_object] = [] if !files.key?(dim_object)
          files[dim_object] << File.basename(f)
          z += 1
        end
      end
      correct_dims = nil
      if files.keys.length == 1
        correct_dims = files.keys.first
      else
        # find largest dimension and delete others
        correct_dims = files.max_by { |k, v| v.length }[0]
        files_to_delete = files.select { |k, v| k != correct_dims }
        files_to_delete.each do |k, v|
          v.each { |f| FileUtils.remove_file(File.join(input_path, File.basename(f))) }
        end
      end
      if correct_dims.present? && z != 0
        @x = correct_dims[:x]
        @y = correct_dims[:y]
        @z = files[correct_dims].length
        @linear_scale_factor = linear_scale_factor
      else
        raise "No images or images with dimension error located in image series archive"
      end
    end

    def image_dims(f)
      w = nil
      h = nil
      img = MiniMagick::Image.open(f)
      if img.valid?
        w = img.width
        h = img.height
      end
      img.destroy!
      return w, h
    end

    def vf # voxel volume factor, i.e. approx. length on a side in pixels
      400.0
    end

    def linear_scale_factor
      ( (vf**3) / (x.to_f * y.to_f * z.to_f) )**( 1.0/3.0 )
    end

    def scale_images
      fiji = Morphosource::Derivatives::Fiji.new(input_path, scaled_path, linear_scale_factor)
      fiji.call
    end

    def tif_to_raw_dcm
      new_x, new_y, new_z, new_slice_thickness = new_spacing
      alembic = Morphosource::Derivatives::Alembic.new(scaled_path, raw_dcm_file_path, new_x, new_y, new_z, new_slice_thickness)
      alembic.call
    end

    def new_spacing
      # height and width
      new_x = ( x.to_f * x_spacing.to_f ) / new_dim(x)
      new_y = ( y.to_f * y_spacing.to_f ) / new_dim(y)

      # depth
      z_total = ( z_spacing.to_f * (z.to_f - 1.0) ) + slice_thickness.to_f
      new_slice_thickness = ( slice_thickness.to_f * z.to_f) / new_dim(z)
      new_z = ( z_total  - new_slice_thickness ) / ( new_dim(z) - 1 )
      new_z = 0.0 if new_z < 0.0

      return new_x, new_y, new_z, new_slice_thickness
    end

    def new_dim(var)
      ( var.to_f * linear_scale_factor ).to_i
    end

    def compress_dcm
      dcmcjpeg = Morphosource::Derivatives::Dcmcjpeg.new(raw_dcm_path, output_path)
      dcmcjpeg.call
    end

    def write_files
      output_file_service.call(output_file_path, directives)
    end

    def cleanup_tmp_files
      begin
        FileUtils.rm_r tmp_dir_path
      rescue Errno::ENOTEMPTY
        puts "in cleanup_tmp_files: Directory '#{tmp_dir_path}' not empty."
      end
    end
  end
end
