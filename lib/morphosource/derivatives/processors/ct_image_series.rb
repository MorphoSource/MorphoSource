require 'fileutils'
require 'zip'

module Morphosource::Derivatives::Processors
	class TimeoutError < Hydra::Derivatives::TimeoutError
  	end

	class CTImageSeries < Hydra::Derivatives::Processors::Processor
		attr_accessor :tmp_dir_path, :img_coll, :ext
    attr_accessor :input_path, :scaled_path, :raw_dcm_path, :output_path, :manifest_path
    attr_accessor :raw_dcm_file_path, :output_file_path
    attr_accessor :x, :y, :z, :linear_scale_factor
    attr_accessor :slice_thickness, :unit, :x_spacing, :y_spacing, :z_spacing
    attr_accessor :derivatives_tmp_path

		class_attribute :timeout

    def acceptable_image_formats
      ['.dcm', '.dicom', '.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg']
    end

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

        
        @x_spacing = directives.fetch(:x_spacing, 1).presence || 1
        @y_spacing = directives.fetch(:y_spacing, 1).presence || 1
        @z_spacing = directives.fetch(:z_spacing, 0).presence
        @slice_thickness = directives.fetch(:slice_thickness, 0).presence || 0
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
          locate_images
          if !img_coll
            return
          end 
          
          # extract and process images
          extract_images
          uncompress_dcm if ext == '.dcm'
          extract_image_metadata
          scale_images
          tif_to_raw_dcm
          compress_dcm
          
      		# place files
      		write_files
        rescue StandardError => e
          raise e
        ensure
    		  cleanup_tmp_files
        end
    	end

    def derivatives_tmp_path
      @derivatives_tmp_path = Hyrax.config.derivatives_tmp_path
    end

    def correct_spacing_scale
      unit_factors = { 'Cm': 10.0, 'M': 1000.0, 'Km': 1e6, 'In': 25.4, 'Ft': 304.8, 'Mi': 1.609e+6 }
      uf = unit_factors[unit]
      [x_spacing, y_spacing, z_spacing, slice_thickness].each { |var| var = var * uf }
    end

    def locate_images
      # get all image files and locations in zip
      img_locs = {}
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
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
        coll_by_ext[k] = max[1] if (max[1].length > 9 || k.downcase == '.dcm' || k.downcase == '.dicom')
      end

      # return largest group of most preferred file type
      acceptable_image_formats.each do |ext|
        if coll_by_ext.key?(ext)
          @img_coll = coll_by_ext[ext]
          @ext = ext
          return
        end
      end
    end

    def extract_images
      Zip::File.open(source_path) do |zip_file|
        img_coll.each do |f|
          f_path = File.join(input_path, File.basename(f))
          zip_file.extract(f, f_path)
        end
      end
    end

    def uncompress_dcm
      dcmdjpeg = Morphosource::Derivatives::Dcmdjpeg.new(input_path, input_path)
      dcmdjpeg.call
    end

    def extract_image_metadata
      x = []
      y = []
      z = 0
      Dir.foreach(input_path) do |f|
        next if f == '.' or f == '..'
        x_dim, y_dim = image_dims(File.join(input_path, File.basename(f)))
        x << x_dim if x_dim
        y << y_dim if y_dim
        z += 1 if x_dim && y_dim
      end
      set_series_metadata(x, y, z)
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

    def set_series_metadata(x, y, z)
      if x.uniq.length != 1 || y.uniq.length != 1 || z == 0
        raise "No images or different types of images located in image series archive"
      else
        @x = x.first
        @y = y.first
        @z = z
        @linear_scale_factor = linear_scale_factor
      end
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
			FileUtils.remove_dir tmp_dir_path
		end
	end
end
