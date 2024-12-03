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
      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      @glb_path = File.join(tmp_dir_path, glb_name)
      @draco_glb_path = File.join(tmp_dir_path, draco_glb_name)

      begin
        if File.extname(source_path).downcase == '.zip' || File.extname(source_path).downcase == '.tar'
          extract_mesh_archive
        end
        create_tmp_nondraco_glb
        create_tmp_draco_glb
        write_draco_glb
      rescue StandardError => e
        cleanup_tmp_files
        raise e
      end
      cleanup_tmp_files
    end

    def derivatives_tmp_path
      @derivatives_tmp_path = Hyrax.config.derivatives_tmp_path
    end

    def extract_mesh_archive
      extracted_files = Morphosource::Files::ArchiveService.new(source_path).extract_archive(tmp_dir_path)
      new_sources = extracted_files.select { |f| acceptable_archive_mesh_formats.include?(File.extname(f).downcase) }
      if new_sources.present?
        @source_path = new_sources.sort_by { |f| acceptable_archive_mesh_formats.index(File.extname(f).downcase)}.first
      else
        raise "Mesh archive does not contain a recognizable mesh file"
      end
    end

    def create_tmp_nondraco_glb
      blender = Morphosource::Derivatives::Blender.new(source_path, glb_path, unit)
      blender.call
    end

    def create_tmp_draco_glb
      Morphosource::Derivatives::GltfTransform.new(
        cli_command: :optimize,
        source_path: glb_path, 
        out_path:    draco_glb_path
      ).call
    end

    def write_draco_glb
      output_file_service.call(File.open(draco_glb_path), directives)
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
