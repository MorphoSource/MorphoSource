require 'hydra/file_characterization/exceptions'
require 'hydra/file_characterization/characterizer'
require 'logger'
module Hydra::FileCharacterization::Characterizers
  class GltfInspectError < RuntimeError
  end

  class GltfInspect < Hydra::FileCharacterization::Characterizer

    protected

      def command_path
        "gltf-inspect"
      end

      def command
        "#{command_path} '#{filename}'"
      end

      # Tool produces JSON if successful, and error text if not. Post-process to produce XML.
      def post_process(raw_output)
        json_output = parse_json(raw_output)
        metadata = parse_metadata(json_output)
        generate_xml(metadata)
      end

      # Try to parse JSON from output or return error
      def parse_json(output)
        return JSON.parse(output.strip)
      rescue JSON::ParserError, TypeError
        raise GltfInspectError("Unable to parse JSON from gltf-inspect, probably due to a gltf-inspect error. Gltf-inspect output:\n#{output}")
      end

      # Parse 3D-specific metadata from JSON
      def parse_metadata(json)
        if json.is_a? Hash
          # mesh geometry (point number, face number, color/texture) metadata
          meshes = json.dig("meshes", "properties")
          if meshes.present?
            mesh_metadata = calc_mesh_metadata(meshes)
          else
            raise GltfInspectError("No mesh data present in gltf-inspect report. Gltf-inspect output:\n#{output}")
          end

          # scene (bounding box and centroid) metadata
          scenes = json.dig("scenes" , "properties")
          if scenes.present?
            scene_metadata = calc_scene_metadata(scenes)
          else
            raise GltfInspectError("No scene data present in gltf-inspect report. Gltf-inspect output:\n#{output}")
          end

          return mesh_metadata.merge(scene_metadata)
        else
          raise GltfInspectError("Gltf-inspect report returned malformed JSON. Gltf-inspect output:\n#{output}")
        end
      end

      # Calculate and return metadata for mesh geometry
      def calc_mesh_metadata(meshes)
        point_count = 0
        face_count = 0
        modes = []
        attributes = []

        meshes.each do |mesh|
          # gltf meshes can be repeated multiple times, instance number accounts for this
          instances = ( mesh["instances"] || 1 ).to_i

          # point/vertex and polygon/face counts add to the scene total
          point_count += ( mesh["vertices"].to_i * instances )
          face_count += ( mesh["glPrimitives"].to_i * instances )

          # add discrete property entries
          modes.concat(mesh["mode"] || [])
          attributes.concat(mesh["attributes"] || [])
        end

        most_common_mode = ( 
          modes.group_by(&:itself).transform_values(&:count).max_by { |mode, cnt| cnt } || 
          []
        )&.first

        spec_modes = {
          "TRIANGLES" => 3, 
          "LINES" => 1, 
          "POINTS" => 0
        }
        edges_per_face = spec_modes[most_common_mode&.strip&.upcase] || spec_modes["TRIANGLES"]

        color_format, vertex_color, has_uv_space, normals_format = calc_attributes(attributes.uniq)

        return {
          point_count: point_count,
          face_count: face_count,
          edges_per_face: edges_per_face,
          color_format: color_format,
          vertex_color: vertex_color,
          has_uv_space: has_uv_space,
          normals_format: normals_format
        }.compact
      end

      def calc_attributes(attributes)
        normals_format = nil
        color_format = nil
        vertex_color = "False"
        has_uv_space = "False"
        
        attributes.each do |attr|
          attr_name = attr.split(":").first.upcase || ""
          
          if attr_name.include?("NORMAL")
            normals_format = "vertex normals"
          end

          if attr_name.include?("COLOR")
            color_format = "vertex color"
            vertex_color = "True"
          end

          if attr_name.include?("TEXCOORD")
            has_uv_space = "True"
          end
        end

        return color_format, vertex_color, has_uv_space, normals_format
      end

      def calc_scene_metadata(scenes)
        bbox_min_x_list = []
        bbox_min_y_list = []
        bbox_min_z_list = []
        bbox_max_x_list = []
        bbox_max_y_list = []
        bbox_max_z_list = []

        scenes.each do |scene|
          bbox_min = scene["bboxMin"]
          if bbox_min && (bbox_min.count == 3)
            bbox_min_x_list.push(bbox_min[0].to_f)
            bbox_min_y_list.push(bbox_min[1].to_f)
            bbox_min_z_list.push(bbox_min[2].to_f)
          end

          bbox_max = scene["bboxMax"]
          if bbox_max && (bbox_max.count == 3)
            bbox_max_x_list.push(bbox_max[0].to_f)
            bbox_max_y_list.push(bbox_max[1].to_f)
            bbox_max_z_list.push(bbox_max[2].to_f)
          end
        end

        bbox_min_x = bbox_min_x_list.min
        bbox_min_y = bbox_min_y_list.min
        bbox_min_z = bbox_min_z_list.min

        bbox_max_x = bbox_max_x_list.max
        bbox_max_y = bbox_max_y_list.max
        bbox_max_z = bbox_max_z_list.max

        bounding_box_x = nil
        bounding_box_y = nil
        bounding_box_z = nil

        centroid_x = nil
        centroid_y = nil
        centroid_z = nil

        if bbox_min_x && bbox_max_x 
          bounding_box_x = bbox_max_x - bbox_min_x
          centroid_x = ( bounding_box_x / 2.0 ) + bbox_min_x
        end
        if bbox_min_y && bbox_max_y
          bounding_box_y = bbox_max_y - bbox_min_y
          centroid_y = ( bounding_box_y / 2.0 ) + bbox_min_y
        end
        if bbox_min_z && bbox_max_z
          bounding_box_z = bbox_max_z - bbox_min_z
          centroid_z = ( bounding_box_z / 2.0 ) + bbox_min_z
        end
        
        return {
          bounding_box_x: bounding_box_x,
          bounding_box_y: bounding_box_y,
          bounding_box_z: bounding_box_z,
          centroid_x: centroid_x,
          centroid_y: centroid_y,
          centroid_z: centroid_z,
        }.compact
      end

      def generate_xml(metadata)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.blender do
            xml.identification do
              xml.identity(format: file_format, mimetype: mimetype) do
                xml.tool do
                  xml.gltfInspectVersion "0.0.1"
                end
              end
            end

            xml.fileinfo do
              xml.filepath filename
              xml.filename File.basename(filename)
              xml.mimetype mimetype
            end

            xml.metadata do
              xml.mesh do
                xml.pointCount metadata[:point_count] if metadata[:point_count].present?
                xml.faceCount metadata[:face_count] if metadata[:face_count].present?
                xml.edgesPerFace metadata[:edges_per_face] if metadata[:edges_per_face].present?
                xml.colorFormat metadata[:color_format] if metadata[:color_format].present?
                xml.normalsFormat metadata[:normals_format] if metadata[:normals_format].present?
                xml.hasUvSpace metadata[:has_uv_space] if metadata[:has_uv_space].present?
                xml.vertexColor metadata[:vertex_color] if metadata[:vertex_color].present?

                xml.boundingboxdimensions do
                  xml.boundingBoxX metadata[:bounding_box_x] if metadata[:bounding_box_x].present?
                  xml.boundingBoxY metadata[:bounding_box_y] if metadata[:bounding_box_y].present?
                  xml.boundingBoxZ metadata[:bounding_box_z] if metadata[:bounding_box_z].present?
                end

                xml.centroid do
                  xml.centroidX metadata[:centroid_x] if metadata[:centroid_x].present?
                  xml.centroidY metadata[:centroid_y] if metadata[:centroid_y].present?
                  xml.centroidZ metadata[:centroid_z] if metadata[:centroid_z].present?
                  xml.centroidMethod "Bounding Box"
                end
              end
            end
          end
        end
        builder.doc.to_s
      end

      def file_format
        File.extname(filename).downcase
      end

      def mimetype
        if (file_format == ".gltf") || (file_format == ".glb")
          "model/gltf+json"
        else
          MIME::Types.type_for(file_format)&.first&.content_type || "application/octet-stream"
        end

        case File.extname(filename).downcase
        when ".gltf", ".glb"
          "model/gltf+json"
        when ""
        end
      end
  end
end
