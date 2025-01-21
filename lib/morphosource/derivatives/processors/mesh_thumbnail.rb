module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  class MeshThumbnail < Hydra::Derivatives::Processors::Processor
    attr_accessor :derivatives_tmp_path
    attr_accessor :thumbnail_path
    attr_accessor :tmp_dir_path

    class_attribute :timeout

    def process
      timeout ? process_with_timeout : create_thumbnail_derivative
    end

    def process_with_timeout
      Timeout.timeout(timeout) { create_thumbnail_derivative }
    rescue Timeout::Error
      raise Morphosource::Derivatives::Processors::TimeoutError, "Unable to process thumbnail derivative\nThe command took longer than #{timeout} seconds to execute"
    end

    protected

    def create_thumbnail_derivative
      # Source file (3D glb mesh derivative) must exist to create thumbnail
      if !File.exist?(source_path)
        raise "Source file (#{source_path}) not found"
      end

      @tmp_dir_path = Rails.root.join(derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      @thumbnail_path = File.join(tmp_dir_path, 'thumbnail.png')

      begin
        Morphosource::Derivatives::Lightbox.new(source_path: source_path, out_path: thumbnail_path).call
        output_file_service.call(thumbnail_path, directives)
      rescue StandardError => e
        cleanup_tmp_files
        raise e
      end
      cleanup_tmp_files
    end

    def derivatives_tmp_path
      @derivatives_tmp_path = Hyrax.config.derivatives_tmp_path
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