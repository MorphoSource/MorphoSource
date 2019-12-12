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
    attr_accessor :glb_path
    attr_accessor :draco_glb_path
    attr_accessor :derivatives_tmp_path

    class_attribute :timeout

    def acceptable_archive_mesh_formats
      ['.obj', '.ply', '.gltf', '.glb']
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
      @unit = directives.fetch(:unit, 'm').to_s.downcase.presence || 'm'
      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      @glb_path = File.join(tmp_dir_path, glb_name)
      @draco_glb_path = File.join(tmp_dir_path, draco_glb_name)

      begin
        extract_mesh_archive if File.extname(source_path).downcase == '.zip'
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
          fpath = File.join(tmp_dir_path, f.name)
          zip_file.extract(f, fpath) unless File.exist?(fpath)
          @source_path = fpath if acceptable_archive_mesh_formats.include? File.extname(f.name).downcase 
        end
      end
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
