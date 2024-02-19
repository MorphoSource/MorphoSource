require 'zip'
require 'archive/tar/minitar'

module Hydra::Works
  class ArchiveContentsCharacterizationService
    # @param [Hydra::PCDM::File] object which has properties to recieve characterization values.
    # @param [String, File] source for characterization to be run on.  File object or path on disk.
    #   If none is provided, it will assume the binary content already present on the object.
    # @param [Hash] options to be passed to characterization.  parser_mapping:, parser_class:, tools:
    def self.run(object, source = nil, options = {})
      new(object, source, options).characterize
    end

    attr_accessor :object, :source, :mapping, :parser_class, :tools, :tmp_dir_path
    attr_accessor :sub_object, :content, :file_name, :accepted_file_count

    def initialize(object, source, options)
      @object       = object
      @source       = source
      @mapping      = options.fetch(:parser_mapping, Hydra::Works::Characterization.mapper)
      @parser_class = options.fetch("parser_class", Hydra::Works::Characterization::FitsDocument)
      @tools        = options.fetch("tool_class", :fits)
      @sub_object = Hydra::PCDM::File.new()
    end

    def characterize
      # Peek inside of archives
      if File.extname(@source).downcase == ".tar"
        @content, @file_name, @accepted_file_count = tar_to_content
      else
        @content, @file_name, @accepted_file_count = zip_to_content
      end
      raise "Error characterizing #{source}: no representative file found" if file_name == nil

      # Extract metadata
      if blender_mesh_file_types.include? File.extname(file_name).downcase
        # Use Blender instead of FITS for characterization
        @parser_class, @tools = blender_options
      elsif gltf_inspect_mesh_file_types.include? File.extname(file_name).downcase
        # Extract all files to temp location and use gltf-inspect instead of FITS for characterization
        if File.extname(file_name).downcase == '.gltf'
          @needs_cleanup = true
          @content = extract_representative_content_and_others
        end
        @parser_class, @tools = gltf_inspect_options
      end
      extracted_md = extract_metadata(content)

      # Process metadata
      terms = parse_metadata(extracted_md)
      store_metadata(terms) # places fields in sub_object (always have to call fields directly)
      transfer_metadata_to_object # places fields in object
      transfer_special_fields_to_object # places mime_type and file_size in object from sub_object
    ensure
      cleanup_tmp_files if @needs_cleanup
    end

    # Gets representative zip file as content.
    # Unlike Morphosource::Works::CharacterizationService, expects source to be a string.
    def zip_to_content
      rep_f = nil
      accepted_file_count = 0
      Zip::File.open(source) do |zip_file|
        zip_file.each do |f|
          next if File.basename(f.name).start_with?('.')
          accepted_file_count = accepted_file_count + 1 if f_priority(f)
          if ( !rep_f && f_priority(f) ) || ( f_priority(f) && f_priority(f) < f_priority(rep_f) )
            rep_f = f
          end
        end
        rep_f = zip_file.first if !rep_f.presence
        return rep_f.get_input_stream, rep_f.name, accepted_file_count if rep_f
      end
    end

    def tar_to_content
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

    def file_is_hidden?(f)
      f.name[0] == '.'
    end

    def file_type_priorities
      ['.dcm', '.dicom', '.glb', '.gltf', '.obj', '.ply', '.stl', '.wrl', '.x3d', '.tiff', '.tif', '.bmp', '.png', '.jpeg', '.jpg', '.svg', '.dng', '.nef', '.crw', '.cr2', '.cr3', '.iiq', '.arw', '.raw', '.rw2']
    end

    def gltf_inspect_mesh_file_types
      ['.glb', '.gltf']
    end

    def blender_mesh_file_types
      ['.obj', '.ply', '.stl', '.wrl', '.x3d']
    end

    def blender_options
      return Hydra::Works::Characterization::BlenderDocument, :blender
    end

    def gltf_inspect_options
      return Hydra::Works::Characterization::BlenderDocument, :gltf_inspect
    end

    def file_name
      @file_name
    end

    def accepted_file_count
      @accepted_file_count
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

    # Extract all archive files to a tmp location
    def extract_representative_content_and_others
      @tmp_dir_path = Rails.root.join(Hyrax.config.derivatives_tmp_path, SecureRandom.uuid)
      Dir.mkdir tmp_dir_path unless File.exist? tmp_dir_path
      content_path = nil

      case File.extname(source).downcase
      when '.zip'
        content_path = extract_representative_content_and_others_zip
      when '.tar'
        content_path = extract_representative_content_and_others_tar
      else
        raise "Archive file extension not valid"
      end

      if content_path
        return open(content_path)
      else
        raise "Previously identified representative file not found in archive when extracting files for characterization"
      end
    end

    def extract_representative_content_and_others_zip
      content_path = nil 
      Zip::File.open(source) do |zip_file|
        zip_file.each do |f|
          next if File.basename(f.name).start_with?('.')

          f_path = File.join(tmp_dir_path, f.name)
          zip_file.extract(f.name, f_path)
          
          if f.name == file_name
            content_path = f_path
          end
        end
      end
      return content_path
    end

    def extract_representative_content_and_others_tar
      content_path = nil
      File.open(source, 'rb') do |file|
        Archive::Tar::Minitar::Reader.open(file) do |tar|
          tar.each do |f|
            next if !f.file? || File.basename(f.name).start_with?('.')

            f_path = File.join(tmp_dir_path, f.name)
            File.new(f_path, 'wb')
            File.open(f_path, 'wb') do |output_file|
              output_file.write(f.read)
            end

            if f.name == file_name
              content_path = f_path
            end
          end
        end
      end
      return content_path
    end

    def extract_metadata(content)
      Hydra::FileCharacterization.characterize(content, file_name, tools) do |cfg|
        cfg[:fits] = Hydra::Derivatives.fits_path
        # get the Blender path from ENV var
        cfg[:blender] = Hyrax.config.blender_path
      end
    end

    # Use OM to parse metadata
    def parse_metadata(metadata)
      omdoc = parser_class.new
      omdoc.ng_xml = Nokogiri::XML(metadata) if metadata.present?
      omdoc.__cleanup__ if omdoc.respond_to? :__cleanup__
      characterization_terms(omdoc)
    end

    # Get proxy terms and values from the parser
    def characterization_terms(omdoc)
      h = {}
      omdoc.class.terminology.terms.each_pair do |key, target|
        # a key is a proxy if its target responds to proxied_term
        next unless target.respond_to? :proxied_term
        begin
          h[key] = omdoc.send(key)
        rescue NoMethodError
          next
        end
      end
      h.delete_if { |_k, v| v.empty? }
    end

    # Assign values of the instance properties from the metadata mapping :prop => val
    def store_metadata(terms)
      terms.each_pair do |term, value|
        property = property_for(term)
        next if property.nil?
        # Array-ify the value to avoid a conditional here
        Array(value).each { |v| append_property_value(property, v) }
      end
    end

    # Check parser_config then self for matching term.
    # Return property symbol or nil
    def property_for(term)
      if mapping.key?(term) && object.respond_to?(mapping[term])
        mapping[term]
      elsif object.respond_to?(term)
        term
      end
    end

    def append_property_value(property, value)
      # We don't want multiple mime_types; this overwrites each time to accept last value
      value = sub_object.send(property) + [value] unless property == :mime_type
      # We don't want multiple heights / widths, pick the max
      value = value.map(&:to_i).max.to_s if property == :height || property == :width
      sub_object.send("#{property}=", value)
    end

    def transfer_special_fields_to_object
      object.send('contents_file_name=', file_name)
      object.send('contents_accepted_file_count=', accepted_file_count)
      special_fields.each { |sf| object.send("contents_#{sf.to_s}=", sub_object.send(sf)) }
    end

    # In special GLTF case that all archive files are extracted, delete files after characterization
    def cleanup_tmp_files
      begin
        FileUtils.rm_r tmp_dir_path
      rescue Errno::ENOTEMPTY
        Rails.logger.debug "in cleanup_tmp_files: Directory '#{tmp_dir_path}' not empty."
      end
    end
  end
end
