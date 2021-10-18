require 'fileutils'
require 'securerandom'
require 'zip'

module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  class Mesh < Hydra::Derivatives::Processors::Processor
    attr_accessor :glb_name
    attr_accessor :draco_glb_name
    attr_accessor :unit
    attr_accessor :tmp_dir_path
    attr_accessor :simplified_mesh_dir_path
    attr_accessor :glb_path
    attr_accessor :draco_glb_path
    attr_accessor :derivatives_tmp_path

    class_attribute :timeout

    def acceptable_archive_mesh_formats
      ['.obj', '.ply', '.gltf', '.glb', '.stl', '.x3d', '.bin', '.wrl']
    end

    def process
      timeout ? process_with_timeout : create_mesh_derivative
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_mesh_derivative }
    rescue Timeout::Error
      raise Morphosource::Derivatives::Processors::TimeoutError, "Unable to process mesh derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    protected

    def create_mesh_derivative
      @glb_name = File.basename(source_path, '.*') + '.glb'
      @draco_glb_name = File.basename(source_path, '.*') + '-draco.glb'
      @unit = directives.fetch(:unit, 'mm').to_s.downcase.presence || 'mm'

      # dir paths
      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      @simplified_mesh_dir_path = File.join(tmp_dir_path, 'simplified_mesh/')
      Dir.mkdir simplified_mesh_dir_path unless File.exist? simplified_mesh_dir_path
      @glb_path = File.join(tmp_dir_path, glb_name)
      @draco_glb_path = File.join(tmp_dir_path, draco_glb_name)

      begin
        extract_mesh_archive if File.extname(source_path).downcase == '.zip'
        meshlab_simplify_mesh if meshlab_simplify_file_types.include?(File.extname(source_path).downcase)
        simplify_textures
        create_tmp_nondraco_glb
        create_tmp_draco_glb
        write_draco_glb
      rescue StandardError => e
        raise e
      ensure
        cleanup_tmp_files
      end
    end

    def derivatives_tmp_path
      @derivatives_tmp_path = Hyrax.config.derivatives_tmp_path
    end

    def extract_mesh_archive
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          next if File.basename(f.name).start_with?('.')
          fpath = File.join(tmp_dir_path, File.basename(f.name))
          zip_file.extract(f, fpath) unless File.exist?(fpath)
          @source_path = fpath if acceptable_archive_mesh_formats.include? File.extname(f.name).downcase 
        end
      end
    end

    def meshlab_simplify_file_types
      ['.obj', '.ply', '.stl']
    end

    def meshlab_simplify_mesh
      simplified_mesh_path = File.join(simplified_mesh_dir_path, File.basename(source_path))
      simplify_mesh = Morphosource::Derivatives::SimplifyMesh.new(source_path, simplified_mesh_path, 1000000)
      simplify_mesh.call # tool checks for output file presence and raises error if not found
      @source_path = simplified_mesh_path
    end

    def simplify_textures
      source_dir = File.dirname(source_path)
      Dir.foreach(source_dir) do |f|
        next if f == '.' or f == '..'
        if texture_file_types.include? File.extname(f).downcase
          simplify_texture_image(File.join(source_dir, f))
        end
      end
    end

    def texture_file_types
      ['.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg']
    end

    def simplify_texture_image(f)
      img = MiniMagick::Image.new(f)
      img.resize('1024x1024>^')
    end

    def create_tmp_nondraco_glb
      blender = Morphosource::Derivatives::Blender.new(source_path, glb_path, unit)
      blender.call # todo add output and error check it
    end

    def create_tmp_draco_glb
      gltf_pipeline = Morphosource::Derivatives::GltfPipeline.new(glb_path, draco_glb_path)
      gltf_pipeline.call # todo add output and error check it
    end

    def write_draco_glb
      output_file_service.call(draco_glb_path, directives)
    end

    def cleanup_tmp_files
      FileUtils.remove_dir tmp_dir_path
    end
  end
end
