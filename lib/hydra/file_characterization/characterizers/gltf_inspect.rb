require 'hydra/file_characterization/exceptions'
require 'hydra/file_characterization/characterizer'
require 'logger'
module Hydra::FileCharacterization::Characterizers
  class GltfInspectError < RuntimeError
  end

  class GltfInspect < Hydra::FileCharacterization::Characterizer

    protected

      def command_path
        if tool_path.present?
          File.join(tool_path, "gltf-inspect")
        else
          "gltf-inspect"
        end
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
            # raise error here
          end

          # scene (bounding box and centroid) metadata
          scenes = json.dig("scenes" , "properties")
          if scenes.present?
            scene_metadata = calc_scene_metadata(scenes)
          else
            # raise error here
          end

          return mesh_metadata.merge(scene_metadata)
        else
          # raise error here
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

        edges_per_face = calc_edges_per_face(modes.uniq)
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

      # Returns list of edges per polygon face values corresponding to GLTF spec modes
      def calc_edges_per_face(modes) 
        # spec has others (line_loop, line_strip, triangle_strip, triangle_fan), not supporting for now
        spec_modes = {
          "TRIANGLES": 3, 
          "LINES": 1, 
          "POINTS": 0
        }
        
        # modes not required, TRIANGLES aka 3 is default
        return modes.count? ? modes.map { |mode| spec_modes[mode.strip.upcase] }.compact : [spec_modes["TRIANGLES"]]
      end

      def calc_attributes(attributes)
        color_format = nil
        vertex_color = nil
        has_uv_space = nil
        normals_format = nil


        attributes.each do |attr|
          attr_name = attr.split(":").first.upcase || ""
          
          if attr_name.include?("NORMAL")
            normals_format = "vertex normals"
          end

          if attr_name.include?("COLOR")
            vertex_color = true
            color_format = "vertex color"
          end

          if attr_name.include?("TEXCOORD")
            has_uv_space = true
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
            xml.identification { xml.identity(format: file_format, mimetype: mimetype) }

            xml.fileinfo do
              xml.filepath { |f| f.name filename }
              xml.filename { |f| f.name File.basename(filename) }
              xml.mimetype { |m| m.name mimetype }
            end

            xml.metadata do
              xml.mesh do
                xml.pointCount { |p| metadata[:point_count] } if metadata[:point_count]
                xml.faceCount { |p| metadata[:face_count] } if metadata[:face_count]
                xml.edgesPerFace { |p| metadata[:edges_per_face] } if metadata[:edges_per_face]
                xml.colorFormat { |p| metadata[:color_format] } if metadata[:color_format]
                xml.normalsFormat { |p| metadata[:normals_format] } if metadata[:normals_format]
                xml.hasUvSpace { |p| metadata[:has_uv_space] } if metadata[:has_uv_space]
                xml.vertexColor { |p| metadata[:vertex_color] } if metadata[:vertex_color]


                xml.boundingboxdimensions do
                  xml.boundingBoxX { |b| metadata[:bounding_box_x] } if metadata[:bounding_box_x]
                  xml.boundingBoxY { |b| metadata[:bounding_box_y] } if metadata[:bounding_box_y]
                  xml.boundingBoxZ { |b| metadata[:bounding_box_z] } if metadata[:bounding_box_z]
                end

                xml.centroid do
                  xml.centroidX { |c| metadata[:centroid_x] } if metadata[:centroid_x]
                  xml.centroidY { |c| metadata[:centroid_y] } if metadata[:centroid_y]
                  xml.centroidZ { |c| metadata[:centroid_z] } if metadata[:centroid_z]
                end
              end
            end
          end
        end
        builder.doc
      end

      # Remove any non-XML output that precedes the <?xml> tag
      # todo: possibly remove blender errors and non-xml output
      def post_process(raw_output)
        md = /\A(.*)(<\?xml.*)\Z/m.match(raw_output)
        logger.warn "----- WARNING ----- Blender produced non-xml output: \"#{md[1].chomp}\"" unless md[1].empty?
        md[2]
      end
  end
end
