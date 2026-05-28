# frozen_string_literal: true
# Taken from Hyrax 5.0.5

module Hyrax
  ##
  # Valkyrie model for `FileSet` domain objects in the Hydra Works model.
  #
  # ## Relationships
  #
  # ### FileSet and Work
  #
  # * Defined: The relationship is defined by the inverse relationship stored in the
  #   work's `:member_ids` attribute.
  # * Tested: The test for the Work class tests the relationship.
  # * FileSet to Work: (n..1)  A FileSet must be in one and only one work. A Work can have zero to many FileSets.
  # * See Hyrax::Work for code to get and set file sets for the work.
  #
  # @example Get Work for a FileSet:
  #       work = Hyrax.custom_queries.find_parent_work(resource: file_set)
  #
  # ### FileSet and FileMetadata
  #
  # * Defined: The relationship is defined by the FileSet's `:file_ids` attribute.
  # * FileSet to FileMetadata: (0..n) A FileSet can have many FileMetadatas. A FileMetadata must be in one and only one FileSet.
  #
  # @example Get all FileMetadata for a FileSet:
  #     file_metadata = Hyrax.custom_queries.find_files(file_set: file_set)
  #
  # @example Attach a File to a FileSet through a FileMetadata. This will create
  #   a FileMetadata for a File object, attach the File to the FileMetadata, and
  #   attach that FileMetadata to a given FileSet.
  #     ::Hyrax::ValkyrieUpload.file(
  #       io: file_io,
  #       filename: "myfile.jpg",
  #       file_set: file_set,
  #       use: pcdm_use,
  #       user: user
  #     )
  #
  # ### FileMetadata and Files
  #
  # * Defined: The relationship is defined by the FileMetadata's `:file_identifier` attribute.
  # * FileMetadata to File: (1..1) A FileMetadata can have one and only one File
  #
  # @example Get a File for a FileMetadata
  #     file = Hyrax.storage_adapter.find_by(id: file_metadata.file_identifier)
  #
  # @see Hyrax::Work
  # @see Hyrax::CustomQueries::Navigators::FindFiles#find_files
  # @see Hyrax::CustomQueries::Navigators::ParentWorkNavigator#find_parent_work
  # @see https://wiki.duraspace.org/display/samvera/Hydra%3A%3AWorks+Shared+Modeling
  class FileSet < Hyrax::Resource
    include Hyrax::ArResource
    include Hyrax::Schema(:core_metadata)
    include Hyrax::Schema(:file_set_metadata)
    include Hyrax::Schema(:file_set_extra_metadata)
    include Morphosource::ArResource
    include Morphosource::ArResourceParentship
    include Morphosource::Works::MimeTypes

    def self.model_name(name_class: Hyrax::Name)
      @_model_name ||= name_class.new(self, nil, 'FileSet')
    end

    class_attribute :characterization_proxy
    self.characterization_proxy = Hyrax.config.characterization_proxy

    attribute :file_ids, Valkyrie::Types::Array.of(Valkyrie::Types::ID) # id for FileMetadata resources

    delegate :download_groups, :download_groups=,
             :download_users,  :download_users=, to: :permission_manager

    # for all file types
    delegate(
      :crc32,
      :file_size,
      :mime_type,
      to: :original_file,
      allow_nil: true
    )

    # for images
    delegate(
      :bits_per_sample,
      :color_space,
      :compression,
      :focal_length,
      :aperture_value,
      :iso_speed_ratings,
      :shutter_speed,
      to: :original_file,
      allow_nil: true
      )

    # for dicom
    delegate(
      :spacing_between_slices,
      :modality,
      :secondary_capture_device_manufacturer,
      :secondary_capture_device_software_vers,
      :file_type_extension,
      :image_type,
      :study_date,
      :series_date,
      :content_date,
      :study_time,
      :series_time,
      :content_time,
      :accession_number,
      :instance_number,
      :image_position_patient,
      :image_orientation_patient,
      :samples_per_pixel,
      :photometric_interpretation,
      :rows,
      :columns,
      :pixel_spacing,
      :slice_thickness,
      :bits_allocated,
      :bits_stored,
      :high_bit,
      :pixel_representation,
      :window_center,
      :window_width,
      :rescale_intercept,
      :rescale_slope,
      :window_center_and_width_explanation,
      :exposure_time,
      :pixel_spacing_calibration_type,
      :contrast_frame_averaging,
      :images_in_acquisition,
      :KVP,
      :generator_power,
      :x_ray_tube_current,
      :container_description,
      :generator_id,
      :detector_description,
      :distance_source_to_patient,
      :distance_source_to_detector,
      :anode_target_material,
      :spiral_pitch_factor,
      :number_of_series_related_instances,
      to: :original_file,
      allow_nil: true
    )

    # for mesh
    delegate(
      :point_count,
      :face_count,
      :edges_per_face,
      :bounding_box_x,
      :bounding_box_y,
      :bounding_box_z,
      :centroid_x,
      :centroid_y,
      :centroid_z,
      :color_format,
      :normals_format,
      :has_uv_space,
      :vertex_color,
      :centroid_method,
      :blender_version,
      :gltf_inspect_version,
      :pymeshlab_version,
      to: :original_file,
      allow_nil: true
    )

    # for zip archive contents
    delegate(
      :contents_all_files,
      :contents_mime_type,
      :contents_file_name,
      :contents_file_size,
      :contents_accepted_file_count,
      to: :original_file,
      allow_nil: true
    )

    # @return [Hyrax::FileMetadata, nil]
    def original_file
      @original_file ||= Hyrax.custom_queries.find_original_file(file_set: self)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      @original_file = nil
    end

    # @return [Valkyrie::ID, nil]
    def original_file_id
      original_file&.id
    end

    # @return [String, Nil] versioned identifier suitable for use in a IIIF manifest
    def iiif_id
      orig_file = original_file
      return nil if orig_file.nil? || orig_file.file_identifier.blank?
      latest_file = Hyrax::VersioningService.latest_version_of(orig_file)
      version = latest_file&.version_id ? Digest::MD5.hexdigest(latest_file.version_id) : nil
      "#{id}/files/#{orig_file.id}#{'/' + version if version}"
    end

    # @return [Hyrax::FileMetadata, nil]
    def thumbnail
      Hyrax.custom_queries.find_thumbnail(file_set: self)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      nil
    end

    # @return [Valkyrie::ID, nil]
    def thumbnail_id
      thumbnail&.id
    end

    # @return [Hyrax::FileMetadata, nil]
    def extracted_text
      Hyrax.custom_queries.find_extracted_text(file_set: self)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      nil
    end

    # @return [Valkyrie::ID, nil]
    def extracted_text_id
      extracted_text&.id
    end

    ##
    # @return [Array] All ids, extensions, mime types, names, and uses
    # @example
    #   [{:id=>"123", :extension=>"pdf", :mime_type=>"application/pdf", :name=>nil, :use=>"OriginalFile"},
    #    {:id=>"234", :extension=>"jpeg", :mime_type=>"application/octet-stream", :name=>"thumbnail", :use=>"ThumbnailImage"}]
    # rubocop:disable Metrics/MethodLength
    def extensions_and_mime_types
      return [] if file_ids.empty?
      Hyrax.custom_queries.find_files(file_set: self).each_with_object([]) do |fm, arr|
        next unless fm.original_filename
        extension = File.extname(fm.original_filename)
        next if extension.empty?
        use = fm.filtered_pcdm_use.first.to_s.split("#").last
        name = use == 'OriginalFile' ? nil : File.basename(fm.original_filename, extension).split('-').last
        arr << {
          id: fm.id.to_s,
          extension: extension[1..], # remove leading '.'
          mime_type: fm.mime_type,
          name: name,
          use: use
        }
      end
      # rubocop:enable Metrics/MethodLength
    end

    ##
    # @return [Valkyrie::ID]
    def representative_id
      id
    end

    ##
    # @return [Boolean] true
    def self.file_set?
      true
    end

    ##
    # @return [Boolean] true
    def self.pcdm_object?
      true
    end

    def media?
      false
    end

    def processing_event?
      false
    end

    # this method is called after CharacterizeJob and CreateDerivativesJob
    def set_final_attributes
      if is_remote_backed?
        # characterization_proxy is a symbol (method name) on Valkyrie FileSets;
        # call send() to get the actual Hyrax::FileMetadata object.
        proxy = send(self.class.characterization_proxy)
        if (!self.mime_type_of_remote.present?) || (self.mime_type_of_remote.include? "message/external-body")
          self.mime_type_of_remote = proxy.mime_type
          proxy.mime_type = "message/external-body; access-type=URL; URL=\"#{import_url}\""
          Hyrax.persister.save(resource: proxy)
          Hyrax.persister.save(resource: self) # self is a Valkyrie resource; self.save raises NoMethodError
        end
        # set_remote_file_health after content_length is set
        member_of.first&.set_remote_file_health
      end
    end

    def is_remote_backed?
      parent = member_of.first
      return false unless parent.present?
      parent.is_remote_backed?
    end

    def has_remote_manifest?
      parent = member_of.first
      return false unless parent.present?
      parent.has_remote_manifest?
    end

    def remote_manifest_url
      member_of.first&.remote_manifest_url
    end

    def remote_origin_url
      member_of.first&.remote_origin_url
    end
  end
end
