require 'fileutils'
require 'securerandom'
require 'zip'

module Morphosource::Derivatives::Processors
  class TimeoutError < Hydra::Derivatives::TimeoutError
  end

  class MeshError < RuntimeError
  end

  class Mesh < Hydra::Derivatives::Processors::Processor
    class_attribute :timeout

    # Working directory path
    attr_accessor :tmp_dir_path

    # File paths
    attr_accessor :obj_path
    attr_accessor :initial_glb_path
    attr_accessor :metalr_glb_path
    attr_accessor :center_glb_path
    attr_accessor :scaled_glb_path
    attr_accessor :draco_glb_path

    # Properties
    attr_accessor :max_texture_size
    attr_accessor :source_point_count

    MESH_FORMATS = ['.obj', '.ply', '.gltf', '.glb', '.stl', '.x3d', '.bin', '.wrl']
    SIMPLIFY_ERROR_LEVELS = [0.00025, 0.0005, 0.00075, 0.001]
    UNIT_DEFAULT = 'mm'
    UNIT_TO_FACTOR = {
      'um' => 0.000001,
      'mm' => 0.001,
      'cm' => 0.01,
       'm' => 1.0,
      'km' => 1000,
      'in' => 0.025400050800102,
      'ft' => 0.304785126485827,
      'mi' => 1609.34
    }
    VERTEX_MAX = 1_000_000

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
      @tmp_dir_path = Rails.root.join(Hyrax.config.derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path

      begin
        file_ext = File.extname(source_path).downcase

        # Extract representative mesh if source is archive
        if file_ext == '.zip' || file_ext == '.tar'
          extract_mesh_archive
          file_ext = File.extname(source_path).downcase # get ext of representative file in archive
        end

        # Pre-processing file conversion based on mesh file format
        case file_ext
        when '.gltf', '.glb'
          @initial_glb_path = @source_path #no-op
        when '.obj'
          @obj_path = @source_path
          convert_obj_to_glb
        when '.ply'
          convert_ply_to_glb
        when *MESH_FORMATS
          convert_mesh_to_obj
          convert_obj_to_glb
        else
          raise "No recognized mesh file format"
        end

        # Process mesh in steps and write final output
        convert_metalr_textures
        center_glb
        scale_glb
        simplify_and_draco_compress_glb
        write_glb
      rescue StandardError => e
        cleanup_tmp_files
        raise e
      end
      cleanup_tmp_files
    end

    # @!group Mesh archives

    def extract_mesh_archive
      extracted_files = Morphosource::Files::ArchiveService.new(source_path).extract_archive(tmp_dir_path)
      new_sources = extracted_files.select { |f| File.file?(f) && MESH_FORMATS.include?(File.extname(f).downcase) }
      if new_sources.present?
        @source_path = new_sources.sort_by { |f| [MESH_FORMATS.index(File.extname(f).downcase), f.count('/'), f] }.first
      else
        raise "Mesh archive does not contain a recognizable mesh file"
      end
    end

    # @!endgroup
    # @!group Mesh file format conversion

    def convert_mesh_to_obj
      obj_name = File.basename(source_path, '.*') + '.obj'
      @obj_path = File.join(tmp_dir_path, obj_name)

      Morphosource::Derivatives::Pymeshlab.new(source_path, obj_path).call
    end

    def convert_obj_to_glb
      initial_glb_name = File.basename(source_path, '.*') + '-initial.glb'
      @initial_glb_path = File.join(tmp_dir_path, initial_glb_name)

      Morphosource::Derivatives::Obj2gltf.new(obj_path, initial_glb_path).call
    end

    def convert_ply_to_glb
      initial_glb_name = File.basename(source_path, '.*') + '-initial.glb'
      @initial_glb_path = File.join(tmp_dir_path, initial_glb_name)

      Morphosource::Derivatives::Trimesh.new(source_path, initial_glb_path).call
    end

    # @!endgroup
    # @!group Mesh texture conversion, centering, and scaling

    # Some GLB models with spec/gloss materials need materials converted to metal/rough workflow
    # https://www.donmccurdy.com/2022/11/28/converting-gltf-pbr-materials-from-specgloss-to-metalrough
    def convert_metalr_textures
      metalr_glb_name = File.basename(source_path, '.*') + '-metalr.glb'
      @metalr_glb_path = File.join(tmp_dir_path, metalr_glb_name)

      Morphosource::Derivatives::GltfTransform.new(
        cli_command: :metalrough,
        source_path: initial_glb_path,
        out_path:    metalr_glb_path
      ).call
    end

    # Center GLB to coordinate origin, pivoting on bottom point ("stand upon grid")
    def center_glb
      center_glb_name = File.basename(source_path, '.*') + '-center.glb'
      @center_glb_path = File.join(tmp_dir_path, center_glb_name)

      Morphosource::Derivatives::GltfTransform.new(
        cli_command: :center,
        source_path: metalr_glb_path,
        out_path:    center_glb_path
      ).call
    end

    # If non-default scale unit specified, scale GLB vertices to meters
    def scale_glb
      scaled_glb_name = File.basename(source_path, '.*') + '-scaled.glb'
      @scaled_glb_path = File.join(tmp_dir_path, scaled_glb_name)
      unit = directives.fetch(:unit, UNIT_DEFAULT) || UNIT_DEFAULT

      # GLTF output must be in meter scale, so any non-meter unit mesh must be scaled
      if unit&.to_s.downcase != 'm'
        Morphosource::Derivatives::GltfScale.new(
          center_glb_path,
          scaled_glb_path,
          scale_factor(unit)
        ).call
        # Also need to re-center the mesh one more time
        Morphosource::Derivatives::GltfTransform.new(
          cli_command: :center,
          source_path: scaled_glb_path,
          out_path:    scaled_glb_path
        ).call
      else
        # Skip this step, just use the centered glb
        @scaled_glb_path = center_glb_path
      end
    end

    # @!endgroup
    # @!group Mesh simplification

    def simplify_and_draco_compress_glb
      @max_texture_size = directives.fetch(:max_texture_size, 1024).to_i
      @source_point_count = directives.fetch(:point_count, 0).to_i

      draco_glb_name = File.basename(source_path, '.*') + '-draco.glb'
      @draco_glb_path = File.join(tmp_dir_path, draco_glb_name)

      create_simplified_derivative
    end

    def create_simplified_derivative
      generate_glb(simplify: source_point_count > VERTEX_MAX)
      metadata = characterize_derivative

      # iteratively simplify mesh further if derivative is still too big
      if metadata[:point_count] > VERTEX_MAX
        SIMPLIFY_ERROR_LEVELS.each do |error|
          # Delete previous simplified glb so derivative tool can check if file generates successfully
          FileUtils.rm(draco_glb_path)

          generate_glb(simplify: true, simplify_error: error)
          metadata = characterize_derivative

          break if metadata[:point_count] < VERTEX_MAX
        end
      end
    end

    def generate_glb(simplify: false, simplify_error: 0.0001)
      gltf_transform = Morphosource::Derivatives::GltfTransform.new(
        cli_command: :optimize,
        source_path: scaled_glb_path,
        out_path:    draco_glb_path,
        opts: {
          max_texture_size: max_texture_size,
          simplify:         simplify,
          simplify_error:   simplify_error
        }
      ).call
    end

    def characterize_derivative
      Hydra::FileCharacterization::Characterizers::GltfInspect.new(draco_glb_path, nil, :json).call
    end

    # @!endgroup
    # @!group File output

    def write_glb
      output_file_service.call(File.open(draco_glb_path), directives)
    end

    # @!endgroup
    # @!group Utility methods

    def cleanup_tmp_files
      begin
        FileUtils.rm_r tmp_dir_path
      rescue Errno::ENOTEMPTY
        Rails.logger.debug "in cleanup_tmp_files: Directory '#{tmp_dir_path}' not empty."
      end
    end

    def scale_factor(unit)
      unit = unit.to_s.downcase

      if UNIT_TO_FACTOR.key? unit
        return UNIT_TO_FACTOR[unit]
      else
        raise Morphosource::Derivatives::Processors::MeshError.new("Unacceptable unit provided for scaling mesh derivative: #{unit}")
      end
    end

    # @!endgroup
  end
end
