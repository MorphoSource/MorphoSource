require 'zip'

module Hydra::Works
  class ZipContentsCharacterizationService < CharacterizationService
    attr_accessor :sub_object, :content, :file_name

    def initialize(object, source, options)
      super
      @sub_object = Hydra::PCDM::File.new()
    end

    def characterize
      @content, @file_name = source_to_content
      raise "Error characterizing #{source}: no representative file found" if file_name == nil
      set_blender_options if mesh_file_types.include? File.extname(file_name).downcase
      extracted_md = extract_metadata(content)
      terms = parse_metadata(extracted_md)
      store_metadata(terms) # places fields in sub_object (always have to call fields directly)
      transfer_metadata_to_object # places fields in object
      transfer_special_fields_to_object # places mime_type and file_size in object from sub_object
    end

    # Gets representative zip file as content.
    # Unlike Morphosource::Works::CharacterizationService, expects source to be a string.
    def source_to_content
      rep_f = nil
      Zip::File.open(source) do |zip_file|
        zip_file.each do |f|
          if ( !rep_f && f_priority(f) ) || ( f_priority(f) && f_priority(f) < f_priority(rep_f) )
            rep_f = f
          end
        end
        rep_f = zip_file.first if !rep_f.presence
        return rep_f.get_input_stream, rep_f.name if rep_f
      end
    end

    def f_priority(f)
      file_type_priorities.find_index(File.extname(f.name).downcase)
    end

    def file_type_priorities
      ['.dcm', '.dicom', '.glb', '.gltf', '.obj', '.ply', '.stl', '.wrl', '.x3d', '.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg']
    end

    def mesh_file_types
      ['.glb', '.gltf', '.obj', '.ply', '.stl', '.wrl', '.x3d']
    end

    def set_blender_options
      parser_class = Hydra::Works::Characterization::BlenderDocument
      tools = :blender
    end

    def file_name
      @file_name
    end

    def append_property_value(property, value)
      # We don't want multiple mime_types; this overwrites each time to accept last value
      value = sub_object.send(property) + [value] unless property == :mime_type
      # We don't want multiple heights / widths, pick the max
      value = value.map(&:to_i).max.to_s if property == :height || property == :width
      sub_object.send("#{property}=", value)
    end

    def transfer_metadata_to_object
      zip_contents_properties.each { |p| object.send("#{p.to_s}=", sub_object.send(p)) }
      # todo add special fields like representative mime type, filename, location, etc.
    end

    def zip_contents_properties
      zip_contents_schemas.inject([]) { |a, s| (a + s.properties.map { |p| p.name } ).uniq }
    end

    def zip_contents_schemas
      [
        Hydra::Works::Characterization::DicomSchema,
        Hydra::Works::Characterization::MeshSchema,
        Hydra::Works::Characterization::ImageExtSchema,
        Hydra::Works::Characterization::AudioSchema,
        Hydra::Works::Characterization::DocumentSchema,
        Hydra::Works::Characterization::ImageSchema,
        Hydra::Works::Characterization::VideoSchema
      ]
    end

    def special_fields
      ['mime_type', 'file_size']
    end

    def transfer_special_fields_to_object
      object.send('contents_file_name=', file_name)
      special_fields.each { |sf| object.send("contents_#{sf.to_s}=", sub_object.send(sf)) }
    end
  end
end
