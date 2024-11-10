# Create derivative asset from OBJ by converting to GLTF
module Morphosource::Derivatives::Processors
  class MeshObjError < RuntimeError
  end

  class MeshObj < MeshGltf
    attr_accessor :convrt_glb_path

    def create_tmp_nondraco_glb
      create_convrt_glb
      create_metalr_glb
      create_center_glb
      create_scaled_glb
    end

    # Convert OBJ to GLB
    def create_convrt_glb
      convrt_glb_name = File.basename(source_path, '.*') + '-convrt.glb'
      @convrt_glb_path = File.join(tmp_dir_path, convrt_glb_name)

      Morphosource::Derivatives::Obj2gltf.new(source_path, convrt_glb_path).call
    end

    # Some GLB models with spec/gloss materials need materials converted to metal/rough workflow
    # https://www.donmccurdy.com/2022/11/28/converting-gltf-pbr-materials-from-specgloss-to-metalrough
    def create_metalr_glb
      metalr_glb_name = File.basename(source_path, '.*') + '-metalr.glb'
      @metalr_glb_path = File.join(tmp_dir_path, metalr_glb_name)

      Morphosource::Derivatives::GltfTransform.new(
        cli_command: :metalrough,
        source_path: convrt_glb_path, 
        out_path:    metalr_glb_path
      ).call
    end

  end
end