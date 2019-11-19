require 'fileutils'
require 'securerandom'
require 'zip'

module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  class Mesh < Hydra::Derivatives::Processors::Processor
    attr_accessor :tmp_dir_path, :archive_path, :glb_path, :glb_texture_path, :glb_draco_path
    attr_accessor :glb_name, :glb_file_path, :glb_texture_file_path, :glb_draco_file_path 
    attr_accessor :unit
    attr_accessor :derivatives_tmp_path

    class_attribute :timeout

    def acceptable_archive_mesh_formats
      ['.obj', '.ply', '.gltf', '.glb']
    end

    def acceptable_texture_image_formats
      ['.jpg', '.jpeg']
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
      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      @archive_path = File.join(tmp_dir_path, 'archive')
      Dir.mkdir archive_path unless File.exist? archive_path
      @glb_path = File.join(tmp_dir_path, 'glb')
      Dir.mkdir glb_path unless File.exist? glb_path
      @glb_texture_path = File.join(tmp_dir_path, 'glb_texture')
      Dir.mkdir glb_texture_path unless File.exist? glb_texture_path
      @glb_draco_path = File.join(tmp_dir_path, 'glb_draco')
      Dir.mkdir glb_draco_path unless File.exist? glb_draco_path

      @glb_name = File.basename(source_path, '.*') + '.glb'
      @glb_file_path = File.join(glb_path, glb_name)
      @glb_texture_file_path = File.join(glb_texture_path, glb_name)
      @glb_draco_file_path = File.join(glb_draco_path, glb_name)
      
      @unit = directives.fetch(:unit, 'm').to_s.downcase.presence || 'm'

      begin
        extract_mesh_archive if File.extname(source_path).downcase == '.zip'
        create_glb
        create_glb_texture
        compress_textures if texture_present?
        create_glb_draco
        write_glb_draco
      rescue StandardError => e
        raise e
      ensure
        # cleanup_tmp_files
      end
    end

    def derivatives_tmp_path
      @derivatives_tmp_path = Hyrax.config.derivatives_tmp_path
    end

    def extract_mesh_archive
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          fpath = File.join(archive_path, f.name)
          zip_file.extract(f, fpath) unless File.exist?(fpath)
          @source_path = fpath if acceptable_archive_mesh_formats.include? File.extname(f.name).downcase 
        end
      end
    end

    def create_glb
      blender = Morphosource::Derivatives::Blender.new(source_path, glb_file_path, unit)
      blender.call # todo add output and error check it
    end

    def create_glb_texture
      gltf_pipeline = Morphosource::Derivatives::GltfPipeline.new(glb_file_path, glb_texture_file_path, draco=false, separate_textures=true)
      gltf_pipeline.call # todo add output and error check it
    end

    def texture_present?
      Dir.foreach(glb_texture_path) do |f|
        next if f == '.' or f == '..'
        return true if is_acceptable_image? f
      end
      return false
    end

    def is_acceptable_image?(f)
      acceptable_texture_image_formats.include? File.extname(f).downcase
    end

    def compress_textures
      Dir.foreach(glb_texture_path) do |f|
        next if f == '.' or f == '..'
        compress_texture(File.join(glb_texture_path, f)) if is_acceptable_image? f
      end
    end

    def compress_texture(f)
      # use image magick to resave jpegs as lower quality
      img = MiniMagick::Image.open(f)
      img.format("jpg", page=0, read_opts={'quality': '50'})
      img.write(f)
    end

    def create_glb_draco
      gltf_pipeline = Morphosource::Derivatives::GltfPipeline.new(glb_texture_file_path, glb_draco_file_path)
      gltf_pipeline.call # todo add output and error check it
    end

    def write_glb_draco
      output_file_service.call(glb_draco_file_path, directives)
    end

    def cleanup_tmp_files
      FileUtils.remove_dir tmp_dir_path
    end
  end
end
