# Create derivative asset from GLTF/GLB 3D asset
module Morphosource::Derivatives::Processors
  class MeshGltfError < RuntimeError
  end

  class MeshGltf < Mesh
    attr_accessor :center_glb_path
    attr_accessor :scaled_glb_path
    attr_accessor :max_texture_size
    attr_accessor :source_point_count

    SIMPLIFY_ERROR_LEVELS = [0.00025, 0.0005, 0.00075, 0.001]
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

    # Center and scale mesh
    def create_tmp_nondraco_glb
      create_center_glb
      create_scaled_glb
    end

    # Translate GLB to coordinate origin
    def create_center_glb
      center_glb_name = File.basename(source_path, '.*') + '-center.glb'
      @center_glb_path = File.join(tmp_dir_path, center_glb_name)

      Morphosource::Derivatives::GltfTransform.new(
        cli_command: :center,
        source_path: source_path, 
        out_path:    center_glb_path
      ).call
    end

    # If non-meter scale unit specified, scale GLB vertices to meters
    def create_scaled_glb
      scaled_glb_name = File.basename(source_path, '.*') + '-scaled.glb'
      @scaled_glb_path = File.join(tmp_dir_path, scaled_glb_name)
      unit = directives.fetch(:unit, nil)

      if unit.present? && (unit&.to_s.downcase != "m")
        Morphosource::Derivatives::GltfScale.new(
          center_glb_path,
          scaled_glb_path,
          scale_factor(unit)
        ).call
      else
        # Skip this step, just use the centered glb
        @scaled_glb_path = center_glb_path
      end
    end

    def scale_factor(unit)
      unit = unit.to_s.downcase

      if UNIT_TO_FACTOR.key? unit
        return UNIT_TO_FACTOR[unit]
      else
        raise Morphosource::Derivatives::Processors::MeshGltfError.new("Unacceptable unit provided for GLTF derivative creation: #{unit}")
      end
    end

    # Create a simplified draco-compressed GLB derivative
    def create_tmp_draco_glb
      @max_texture_size = directives.fetch(:max_texture_size, 1024).to_i
      @source_point_count = directives.fetch(:point_count, 0).to_i

      create_simplified_derivative
    end

    def create_simplified_derivative
      deriv = generate_glb(simplify: source_point_count > VERTEX_MAX)
      metadata = characterize_derivative

      # iterative simplify mesh further if derivative is still too big
      if metadata[:point_count] > VERTEX_MAX
        SIMPLIFY_ERROR_LEVELS.each do |error|
          # Delete previous simplified glb so derivative tool can check file if generates successfully
          FileUtils.rm(draco_glb_path)

          deriv = generate_glb(simplify: true, simplify_error: error)
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
  end
end