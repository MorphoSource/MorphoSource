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
        if File.extname(source_path).downcase == '.zip'
          extract_mesh_zip
        elsif File.extname(source_path).downcase == '.tar'
          extract_mesh_tar
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

    def extract_mesh_tar
      File.open(source_path, 'rb') do |file|
        Archive::Tar::Minitar::Reader.open(file) do |tar|
          tar.each_entry do |entry|
            next if entry.name.start_with?('PaxHeader')
            next if File.basename(entry.name).start_with?('.')
            fpath = File.join(tmp_dir_path, File.basename(entry.name))
            unless File.exist?(fpath)
              File.new(fpath, 'wb')
              File.open(fpath, 'wb') do |output_file|
                output_file.write(entry.read)
              end
              @source_path = fpath if acceptable_archive_mesh_formats.include? File.extname(entry.name).downcase 
            end
          end
        end
      end
    end

    def extract_mesh_zip
      Zip::File.open(source_path) do |zip_file|
        zip_file.each do |f|
          next if File.basename(f.name).start_with?('.')
          fpath = File.join(tmp_dir_path, File.basename(f.name))
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
      begin
        FileUtils.rm_r tmp_dir_path
      rescue Errno::ENOTEMPTY
        Rails.logger.debug "in cleanup_tmp_files: Directory '#{tmp_dir_path}' not empty."
        sleep(15)
        begin
          Dir.foreach(tmp_dir_path) do |item|
            next if item == '.' || item == '..'
            item_path = File.join(tmp_dir_path, item)
            if File.file?(item_path)
              File.delete(item_path)
            elsif File.directory?(item_path)
              FileUtils.rm_r(item_path)
            end
          end
          Dir.delete(tmp_dir_path)
        rescue Exception => e
          Rails.logger.debug "Exception #{e.message}"
        end
      end
    end

  end
end
