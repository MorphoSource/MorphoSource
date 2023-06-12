require 'archive/tar/minitar'
require 'stringio'

module Hydra::Works
  class TarContentsCharacterizationService
    def self.run(object, source = nil, options = {})
      new(object, source, options).characterize
    end

    attr_accessor :object, :source, :mapping, :parser_class, :tools
    attr_accessor :sub_object, :content, :file_name, :accepted_file_count

    def initialize(object, source, options)
      @object = object
      @source = source
      @mapping = options.fetch(:parser_mapping, Hydra::Works::Characterization.mapper)
      @parser_class = options.fetch("parser_class", Hydra::Works::Characterization::FitsDocument)
      @tools = options.fetch("tool_class", :fits)
      @sub_object = Hydra::PCDM::File.new()
    end

    def characterize
      @content, @file_name, @accepted_file_count = source_to_content
      raise "Error characterizing #{source}: no representative file found" if file_name.nil?
      @parser_class, @tools = blender_options if mesh_file_types.include? File.extname(file_name).downcase
      extracted_md = extract_metadata(content)
      terms = parse_metadata(extracted_md)
      store_metadata(terms)
      transfer_metadata_to_object
      transfer_special_fields_to_object
    end

# todo: combine this service with ZipContentsCharacterizationService
# since only a different source_to_content method for TAR is needed
def source_to_content
  rep_f = nil
  rep_f_content = nil
  accepted_file_count = 0

  Archive::Tar::Minitar.open(source) do |tar|
    tar.each do |f|
      next if !f.file? || File.basename(f.name).start_with?('.')

      puts f.name
      puts f_priority(f)
      accepted_file_count = accepted_file_count + 1 if f_priority(f) 
      if ( !rep_f && f_priority(f) ) || ( f_priority(f) && f_priority(f) < f_priority(rep_f) )
        rep_f = f
        rep_f_content = rep_f.read
      end
    end
    if !rep_f.presence
      rep_f = zip_file.first 
      rep_f_content = rep_f.read
    end

    return rep_f_content, rep_f.name, accepted_file_count if rep_f
  end
end

    def f_priority(f)
      file_type_priorities.find_index(File.extname(f.name).downcase)
    end

    def file_type_priorities
      ['.dcm', '.dicom', '.glb', '.gltf', '.obj', '.ply', '.stl', '.wrl', '.x3d', '.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg', '.svg', '.dng', '.nef', '.crw', '.cr2', '.cr3', '.iiq', '.arw', '.raw', '.rw2']
    end

    def mesh_file_types
      ['.glb', '.gltf', '.obj', '.ply', '.stl', '.wrl', '.x3d']
    end

    def blender_options
      return Hydra::Works::Characterization::BlenderDocument, :blender
    end

    def file_name
      @file_name
    end

    def accepted_file_count
      @accepted_file_count
    end

    def transfer_metadata_to_object
      tar_contents_properties.each { |p| object.send("#{p.to_s}=", sub_object.send(p)) }
    end

    def tar_contents_properties
      tar_contents_schemas.inject([]) { |a, s| (a + s.properties.map(&:name)).uniq }
    end

    def tar_contents_schemas
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
      object.send('contents_accepted_file_count=', accepted_file_count)
      special_fields.each { |sf| object.send("contents_#{sf.to_s}=", sub_object.send(sf)) }
    end

    def extract_metadata(content)
      Hydra::FileCharacterization.characterize(content, file_name, tools) do |cfg|
        cfg[:fits] = Hydra::Derivatives.fits_path
        cfg[:blender] = Hyrax.config.blender_path
      end
    end

    def parse_metadata(metadata)
      omdoc = parser_class.new
      omdoc.ng_xml = Nokogiri::XML(metadata) if metadata.present?
      omdoc.__cleanup__ if omdoc.respond_to?(:__cleanup__)
      characterization_terms(omdoc)
    end

    def characterization_terms(omdoc)
      h = {}
      omdoc.class.terminology.terms.each_pair do |key, target|
        next unless target.respond_to?(:proxied_term)
        begin
          h[key] = omdoc.send(key)
        rescue NoMethodError
          next
        end
      end
      h.delete_if { |_k, v| v.empty? }
    end

    def store_metadata(terms)
      terms.each_pair do |term, value|
        property = property_for(term)
        next if property.nil?
        Array(value).each { |v| append_property_value(property, v) }
      end
    end

    def property_for(term)
      if mapping.key?(term) && object.respond_to?(mapping[term])
        mapping[term]
      elsif object.respond_to?(term)
        term
      end
    end

    def append_property_value(property, value)
      value = sub_object.send(property) + [value] unless property == :mime_type
      value = value.map(&:to_i).max.to_s if property == :height || property == :width
      sub_object.send("#{property}=", value)
    end
  end
end
