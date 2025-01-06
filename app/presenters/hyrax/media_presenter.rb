# frozen_string_literal: true

require 'active_support/core_ext/numeric/conversions'
# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter
    include ActionView::Helpers::NumberHelper
    include Morphosource::PresenterMethods
    include MorphosourceHelper
    include MediaFinderHelper

    # Attributes from device solr document
    delegate :device_organization_title, :device_organization_institution_name,
      to: :device, allow_nil: true

    # Attributes from device solr document with device prefix (device_$)
    delegate :creator, :description, :id, :modality, :title,
      to: :device, prefix: true, allow_nil: true

    # Attributes from imaging event solr document
    delegate :acquisition_type, :amperage, :background_removal, :detector_configuration,
      :detector_pixels_x, :detector_pixels_y, :detector_pixel_size_x, :detector_pixel_size_y,
      :detector_type, :exposure_time, :flux_normalization, :focal_length_type, :frame_averaging,
      :ie_filter, :ie_modality, :lens_make, :lens_model, :light_source, :optical_magnification,
      :phase_contrast, :pixel_spacing_calibration, :power, :projections, :rotation_number,
      :shading_correction, :slide_type, :source_detector_distance, :source_object_distance,
      :surrounding_material, :voltage, :xray_tube_type, :target_material, :target_type,
      to: :imaging_event, allow_nil: true

    # Attributes from imaging event solr document with prefix (imaging_event_$)
    delegate :creator, :date_created, :software, :description, :description_attachment_url, :reference_attachment_url,
      to: :imaging_event, prefix: true, allow_nil: true

    # Attributes from physical object solr document (biological specimen or cultural heritage object)
    delegate :catalog_number, :cho_type, :collection_code, :idigbio_uuid, :institution_code,
      :material, :occurrence_id, :short_title, :vouchered,
      to: :physical_object, allow_nil: true

    # Attributes from physical object solr document with prefix (physical_object_$)
    delegate :title,
      to: :physical_object, prefix: true, allow_nil: true

    # Attributes from FileSet solr document
    delegate :"archive?", :bits_allocated, :bits_per_sample,
      :bounding_box_x, :bounding_box_y, :bounding_box_z,
      :centroid_x, :centroid_y, :centroid_z, :centroid_method, :columns,
      :contents_accepted_file_count, :contents_file_name, :contents_mime_type,
      :color_format, :color_space, :compression, :face_count,
      :has_uv_space, :height, :normals_format, :original_file_id, :point_count, :rows, :vertex_color,
      :width,
      to: :representative_presenter, allow_nil: true

    # Attributes from Media solr document
    delegate :access_control_id, :agreement_uri, :ark, :cite_as, :depositor, :description, :doi,
      :download_reviewer, :fileset_accessibility, :fileset_visibility, :funding,
      :human_readable_media_type, :identifier, :imaging_event_id, :is_remote_backed, :map_type,
      :media_organization_id, :media_organization, :media_type, :morphosource_use_agreement_type,
      :number_of_images_in_set, :organization_transfer_on_publish, :orientation, :part,
      :permits_3d_use, :permits_commercial_use, :physical_object_id, :physical_object_type,
      :preview_mode, :publication_status_label, :related_url, :remote_manifest_url,
      :remote_origin_url, :required_archival_of_published_derivatives, :rights_holder, :scale_bar,
      :series_type, :short_description, :side, :slice_thickness, :taxonomies_titles, :unit,
      :user_with_ownership, :x_spacing, :y_spacing, :z_spacing, :short_title,
      to: :solr_document

    attr_accessor :file_status

    self.collection_presenter_class = Morphosource::CollectionPresenter

    # @param [SolrDocument] solr_document
    # @param [Ability] current_ability
    # @param [ActionDispatch::Request] request the http request context. Used so
    #                                  the GraphExporter knows what URLs to draw.
    def initialize(solr_document, current_ability, request = nil)
      # File status used by controller and other methods to detect when file has recently been added
      @file_status = ""
      super(solr_document, current_ability, request)
    end

    ### MEDIA FIELDS AND METHODS ###

    #
    # Media custom agreement attachment file (PDF, DOCX, or TXT) URL
    #
    # @return [Array<String>] Media custom agreement attachment file (PDF, DOCX, or TXT) URL
    #
    def attachment_url
      @attachment_url ||= get_attachment("agreement")
    end

    #
    # MorphoSource usage agreement PDF file name
    #
    # @return [String] MorphoSource usage agreement PDF file name
    #
    def aup_path
      return "ms_usage_#{media_permissions_string}.pdf"
    end

    #
    # Is Media published?
    #
    # @return [Boolean] <description>
    #
    def is_published?
      ["open", "restricted_download"].include? fileset_accessibility&.first
    end

    #
    # State of Media permissions settings expressed as a shorthand string
    #
    # @return [String] Media permissions settings shorthand string
    #
    def media_permissions_string
      if morphosource_use_agreement_type&.first == 'Permissive'
        "permissive"
      else
        comm = Morphosource::CommercialUseTypesService
          .fetch(permits_commercial_use&.first, "short") { "comm_no" }
        arch = Morphosource::RequiredArchivalOfPublishedDerivativesTypesService
          .fetch(required_archival_of_published_derivatives&.first, "short") { "rearc_ms" }
        thre = Morphosource::ThreeDUseTypesService
          .fetch(permits_3d_use&.first, "short") { "3d_limited" }

        "std_#{comm}_#{arch}_#{thre}"
      end
    end

    #
    # Organization transfer ownership request for Media if one exists
    #
    # @return [ProxyDepositRequest, nil] Organization transfer ProxyDepositRequest or nil if none
    #
    def organization_transfer
      @organization_transfer ||= ProxyDepositRequest.where(work_id: id, organization_transfer: true)&.first
    end

    #
    # Should interactive/embeddable preview be displayed?
    #
    # @return [Boolean] Interactive/embeddable preview enabled or not
    #
    def preview_in_3D?
      !preview_mode.present? || preview_mode&.first == "" || preview_mode&.first == "Interactive/Embeddable"
    end

    #
    # First taxonomy title
    #
    # @return [String] First taxonomy title
    def taxonomy_title
      taxonomies_titles&.first || ""
    end

    # Media fund code data

    #
    # Associations between Media and Fund Codes
    #
    # @return [Array<FundCodeMediaAssociation>] Array of associations between Media and Fund Codes
    #
    def fund_code_associations
      @fund_code_associations ||= begin
        FundCodeMediaAssociation
          .joins(:fund_code)
          .select('fund_code_media_associations.*, fund_codes.title, fund_codes.description, fund_codes.can_add_media')
          .where(media: id)
          .to_a
      end
    end

    #
    # All Fund Codes associated with Media
    #
    # @return [Array<FundCode>] Array of Fund Codes associated with Media
    #
    def fund_codes
      @fund_codes ||= begin
        FundCode
          .joins(:fund_code_media_associations)
          .where(fund_code_media_associations: { media: id })
          .to_a
      end
    end

    ### MEDIA PREVIEW AND DERIVATIVE METHODS ###

    #
    # Previewable derivative asset present for Media and FileSet?
    #
    # @return [Boolean] Preview derivative present or not
    #
    def derivative_present?
      return false unless representative_presenter.present?
      d = Morphosource::DerivativePath.derivatives_for_reference(representative_presenter)
      if representative_presenter.image? && !file_size.present?
        return false
      elsif representative_presenter.mesh? || representative_presenter.volume?
        d = d.select { |x| !x.include?('thumbnail') }
      end
      return d.present?
    end

    #
    # Can previewable derivative asset by displayed by Universal Viewer?
    #
    # @return [Boolean] Derivative preview viewable by UV or not
    #
    def universal_viewable_ready?
      return false unless representative_presenter.present?
      ( representative_presenter.image? || representative_presenter.mesh? || representative_presenter.video? || representative_presenter.volume? ) &&
      ( members_include_viewable_image? || members_include_viewable_mesh? || members_include_viewable_video? || members_include_viewable_volume? )
    end

    #
    # Universal Viewer preview ready?
    #
    # @return [Boolean] Universal Viewer ready or not
    #
    def universal_viewer?
      representative_id.present? &&
        representative_presenter.present? &&
        Hyrax.config.iiif_image_server? &&
        universal_viewable_ready?
    end

    # FileSet fields

    #
    # XYZ bounding box dimensions for mesh Media
    #
    # @return [String, nil] String label collating XYZ bounding box lengths if present
    #
    def bounding_box_dimensions
      if bounding_box_x.present? && bounding_box_y.present? && bounding_box_z.present?
        [ bounding_box_x.first, bounding_box_y.first, bounding_box_z.first].
          map { |n| number_with_precision(n, precision: 3) }.join(", ")
      end
    end

    #
    # XYZ centroid location coordinates for mesh Media
    #
    # @return [String, nil] String label collating XYZ centroid location coordinates if present
    #
    def centroid_location
      if centroid_x.present? && centroid_y.present? && centroid_z.present?
        centroid_label = [ centroid_x.first, centroid_y.first, centroid_z.first,].
          map { |n| number_with_precision(n, precision: 3) }.join(", ")
        if centroid_method&.first.present?
          centroid_label += " (#{centroid_method&.first})"
        end
        return centroid_label
      end
    end

    #
    # FileSet binary file size
    #
    # @return [String] Human-readable formatted numeric string for file size
    #
    def file_size
      @file_size ||= begin
        fs = representative_presenter&.file_size.to_i || 0
        fs == 0 ? "" : number_to_human_size(fs)
      end
    end

    #
    # Count of files in a single location of accepted file type for archive ZIP/TAR file.
    # For Volumetric Image Series, this expresses the number of images in the primary series of the archive.
    #
    # @return [String] Human-readable formatted numeric string for number of files
    #
    def accepted_file_count
      @accepted_file_count ||= begin
        fc = contents_accepted_file_count&.first.to_i || 0
        fc == 0 ? "" : fc.to_s(:delimited)
      end
    end

    def archive_files
      @archive_files ||= begin
        if (
          archive? &&
          representative_presenter&.contents_all_files.present? &&
          (all_files = JSON.parse(representative_presenter&.contents_all_files)).present? &&
          all_files.is_a?(Array)
        )
          all_files
        end
      end
    end

    #
    # MIME type of either FileSet binary file itself or a representive file in an archive file
    #
    # @deprecated Use file_types instead
    #
    # @return [String] MIME type of file itself or archive file content or "unknown" if no other
    #
    def mime_type
      @mime_type ||= begin
        representative_presenter&.contents_mime_type&.first || representative_presenter&.mime_type || "unknown"
      end
    end

    #
    # File type label from mime type of either FileSet binary file itself or a representive file in an archive file
    #
    # @return [String] MIME type of file itself
    #
    def file_types
      @file_type ||= begin
        [
          Morphosource::MimeTypesService.label(representative_presenter&.mime_type),
          Morphosource::MimeTypesService.label(representative_presenter&.contents_mime_type&.first)
        ].compact.join(", ")
      end
    end

    #
    # MIME type of representive file in an archive file
    #
    # @return [String] MIME type of archive file content
    #
    def archive_representative_file_type
      @archive_representative_file_type ||= begin
        Morphosource::MimeTypesService.label(representative_presenter&.contents_mime_type&.first)
      end
    end

    #
    # Color depth for image or image series Media, may derive from bits allocated or bits per sample
    # Value comes from different attributes depending on the file type.
    # If multiple values are present (e.g., "8 8 8"), they are concatenated with "/".
    #
    # @return [String] String label describing color depth
    #
    def color_depth
      mime_type.match(/(dcm|dicom)/i) ? bits_allocated&.first.to_s : bits_per_sample&.first.to_s.gsub(/\s/, '/')
    end

    #
    # Image height in pixels, may derive from a height field or for DICOM from a rows field
    #
    # @return [String] Image height in pixels
    #
    def image_height
      mime_type.match(/(dcm|dicom)/i) ? rows&.first.to_s : height.to_s
    end

    #
    # Image width in pixels, may derive from a width field or for DICOM from a columns field
    #
    # @return [String] Image width in pixels
    #
    def image_width
      mime_type.match(/(dcm|dicom)/i) ? columns&.first.to_s : width.to_s
    end

    #
    # Origin of local or remote file. Unlike Media model method, returns empty string if origin is local.
    #
    # @return [String] Remote if origin is remote, otherwise empty string
    #
    def file_origin
      is_remote_backed ? "Remote" : ""
    end

    #
    # Is original file for FileSet ready to be examined, or is it still ingesting?
    #
    # @return [Boolean] Original file of FileSet ready or not
    #
    def file_set_original_file_ready
      !( !original_file_id.present? || ( is_remote_backed && !representative_presenter&.mime_type.present? ) )
    end

    #
    # FileSet file name or full remote URL label
    #
    # @return [String] For local files, filename; for remote files, remote URL
    #
    def file_label
      is_remote_backed ? ( remote_origin_url&.first || "" ) : ( representative_presenter&.label || "" )
    end

    #
    # FileSet file name without any path or, for remote files, URL
    #
    # @return [String] Filename
    #
    def file_label_basename
      File.basename(file_label || "")
    end

    #
    # File name for representative file within archive
    #
    # @return [String] Filename
    #
    def archive_representative_file_label_basename
      File.basename(representative_presenter&.contents_file_name&.first || "")
    end

    ### DEVICE FIELDS ###

    #
    # Combined device name and facility name label
    #
    # @return [String] Combined device name and facility name label
    #
    def device_and_facility

      @device_and_facility ||= link_to(device_label, Rails.application.routes.url_helpers.hyrax_device_path(device_id)) + ", #{device_organization_institution}"
    end

    #
    # Device name label
    #
    # @return [String] Device name label
    #
    def device_label
      @device_label ||= "#{ device_creator&.first || "" } #{ device_title&.first }".strip
    end

    #
    # Device modality label list
    #
    # @return [String] Device modality label list
    #
    def device_modality_labels
      @device_modality_labels ||= device_modality.
        map { |dm| Morphosource::ModalitiesService.new.label(dm) }.join(", ")
    end

    #
    # Device organization parent organization name and institution name label
    #
    # @return [String] Device organization name and institution name label
    #
    def device_organization_institution
      @device_organization_institution ||= begin
        "#{ device_organization_title&.first || "Unknown Organization" } (#{ device_organization_institution_name&.first || "Unknown Institution"})"
      end
    end

    #
    # Imaging Event modality label
    #
    # @return [String] Imaging Event modality label
    #
    def imaging_event_modality
      @imaging_event_modality ||= Morphosource::ModalitiesService.new.label(ie_modality&.first)
    end

    #
    # Lens formatted label for photography and photogrammetry Imaging Event
    #
    # @return [String] Formatted lens description label
    #
    def lens
      @lens ||= "#{lens_make&.first} #{lens_model&.first}".strip
    end

    #
    # Collected other details label for photography and photogrammetry Imaging Event
    #
    # @return [String] Other details label for photography and photogrammetry
    #
    def other_details
      @other_details ||= begin
        other_details = []
        other_details << focal_length_type&.first + " focal length" if focal_length_type.present?
        other_details << light_source&.first + " light" if light_source.present?
        other_details << background_removal&.first if background_removal.present?
        other_details.join(' / ')
      end
    end

    ### PHYSICAL OBJECT FIELDS ###

    #
    # URL link to physical object show page depending on physical object type (biological, cultural)
    #
    # @return [String, nil] Physical object show page link or nil if no physical object
    #
    def physical_object_link
      return nil if !physical_object_id.present?
      @physical_object_link ||= begin
        if physical_object_type == "Biological Specimen"
          Rails.application.routes.url_helpers.specimen_showcase_path(physical_object_id&.first)
        elsif physical_object_type == "Cultural Heritage Object"
          Rails.application.routes.url_helpers.cho_showcase_path(physical_object_id&.first)
        end
      end
    end

    #
    # If physical object has an iDigBio UUID, source is iDigBio
    #
    # @return [String] Source of external record
    #
    def source_of_record
      idigbio_uuid.present? ? "iDigBio" : ""
    end

    ### PROCESSING EVENT FIELDS AND METHODS ###

    #
    # Prepare and process data for processing events upstream from Media
    #
    # @return [Array<Hash>] Array of data hashes for individual processing events
    #
    def processing_events_data
      @processing_events_data ||= begin
        all_parent_works.each_with_object([]).with_index do |(work, data), idx|
          if work&.has_model&.first == "ProcessingEvent" && idx > 0
            # Child is media, either this presenter instance or next parent work solr data
            child = ( idx == (all_parent_works.count - 1) ) ? self : all_parent_works[idx + 1]

            # Parent is media or imaging event
            parent = all_parent_works[idx - 1]
            parent_is_media = parent&.has_model&.first == "Media"

            data << {
              id: work.id,
              creator: work.creator,
              date_created: work.date_created,
              software: [work.software&.join(', ')],
              description: work.description,
              description_attachment: work.description_attachment_url
            }.merge(
                processing_activity_items: processing_event_activity_parsed(work),
                child: child,
                parent: parent,
                parent_is_media: parent_is_media
              )
          end
        end
      end
    end

    #
    # Number of processing events upstream from Media
    #
    # @return [Integer] Processing Events count
    #
    def processing_event_count
      @processing_event_count ||= processing_events_data.count
    end

    #
    # Number of processing event activity steps upstream from Media
    #
    # @return [Integer] Processing Event activity steps count
    #
    def processing_activity_count
      @processing_activity_count ||= processing_events_data.
        map { |pe| pe[:processing_activity_items] }.flatten.count
    end

    # This should be the last processing event in the data array, but we check to make sure

    #
    # Processing Event that produced this Media. Processing Event immediately upstream from Media.
    #
    # @return [Hash] Processing Event data hash for Processing Event producing this Media
    #
    def this_media_processing_event
      @this_media_processing_event ||= processing_events_data.reverse.find { |pe| pe[:child] == self }
    end

    #
    # Parse Processing Event activity steps
    #
    # @param [SolrDocument] pe Processing Event SolrDocument
    #
    # @return [Array<Hash>] Array of Hashes of Processing Event activity step data
    #
    def processing_event_activity_parsed(pe)
      ( pe.processing_activity || [] ).
        map { |pa| processing_activity_hash(pa) }.sort_by { |hsh| hsh["Step"] }
    end

    ### METHODS FINDING OTHER WORKS RELATED TO MEDIA UPSTREAM OR DOWNSTREAM IN TREE HIERARCHY ###

    #
    # Find all "parent" works upstream from Media in hierarchy. By default, limit of 50 works above
    # will be found.
    #
    # @return [Array<SolrDocument>] Array of SolrDocuments of parent works
    #
    def all_parent_works
      @all_parent_works ||= parent_works(solr_document)
    end

    #
    # Find all "parent" media upstream from this Media in hierarchy, based on all_parent_works.
    # Affected by 50 work limit from all_parent_works.
    #
    # @return [Array<SolrDocument>] Array of SolrDocuments of parent Media works
    #
    def parent_media
      @parent_media ||= all_parent_works.select { |doc| doc&.has_model&.first == "Media" }
    end

    #
    # IDs of parent Media works upstream from this Media.
    #
    # @return [Array<String>] Array of parent Media IDs
    #
    def parent_media_id_list
      @parent_media_id_list ||= parent_media.map { |w| w.id }
    end

    #
    # Count of parent Media works upstream from this Media.
    #
    # @return [String] Parent Media works count label
    #
    def parent_media_count
      parent_media.count.to_s
    end

    #
    # Top-most or "first" parent Media work upstream from this Media.
    # First media in any image processing chain. May not be present if this Media has no parents.
    #
    # @return [SolrDocument, nil] Top or first parent Media work
    #
    def top_parent_media
      parent_media&.first
    end

    #
    # Immediate or bottom-most parent Media work upstream from this Media.
    # This is the Media work that led most immediately and directly to this Media.
    #
    # @return [SolrDocument, nil] Direct, immediate, or bottom parent Media work
    #
    def direct_parent
      parent_media&.last
    end

    #
    # Array of top and direct parent media. May include nothing, 2 media, or 1 media (if top==direct).
    #
    # @return [Array<SolrDocument>] Array of top and direct parent media.
    #
    def top_and_direct_parents
      [ top_parent_media, direct_parent ].compact.uniq(&:id)
    end

    #
    # Find direct next-generation "child" Media works downstream from Media in hierarchy.
    #
    # @return [Array<SolrDocument>] Array of SolrDocuments of child Media works
    #
    def child_media
      @child_media ||= direct_child_media_works(solr_document)
    end

    #
    # Find direct next-generation "child" Media works downstream from Media in hierarchy, filtered
    # to Media current user can view.
    #
    # @return [Array<SolrDocument>] Array of SolrDocuments of child Media works
    #
    def viewable_child_media
      @viewable_child_media ||= child_media.select { |m| viewable_related_media.map(&:id).include?(m.id) }
    end

    #
    # IDs of child Media works downstream from this Media. Only the first immediate child generation.
    #
    # @return [Array<String>] Array of child Media IDs
    #
    def child_media_id_list
      @child_media_id_list ||= child_media.map { |w| w.id }
    end

    #
    # All Media works with the same Imaging Event as this Media, except this Media.
    #
    # @return [Array<SolrDocument>] Array of other related Media connected to Imaging Event
    #
    def related_media
      return [] unless imaging_event_id&.first.present?
      ::SolrDocument.where(
        "imaging_event_id_tesim" => imaging_event_id&.first,
        "has_model_ssim" => "Media",
        "-id" => id
      )
    end

    #
    # All Media works with the same Imaging Event as this Media except this Media, filtered to Media
    # current user can view.
    #
    # @return [Array<SolrDocument>] Array of other related Media that current user can view
    #
    def viewable_related_media
      @viewable_related_media ||= related_media.select { |m| current_ability.can?(:read, m) }
    end

    #
    # All viewable related media except those in parent_media and child_media
    #
    # @return [Array<SolrDocument>] Array of non-parent non-child related Media that current user can view
    #
    def other_viewable_related_media
      @other_viewable_related_media ||= begin
        excludeable_media_ids = parent_media_id_list + child_media_id_list
        viewable_related_media.reject { |m| excludeable_media_ids.include?(m.id) }
      end
    end

    #
    # Count number of viewable non-parent media plus parent media (regardless if user can view).
    # User-facing pages provide private media placeholders for unviewable parents, so must count them.
    #
    # @return Integer Number of viewable non-parent media plus parent media (regardless of view status)
    #
    def user_facing_related_media_count
      top_and_direct_parents.count + viewable_child_media.count + other_viewable_related_media.count
    end

    ### WORK HIERARCHY STATE METHODS ###

    #
    # Does this media have an imaging and processing hierarchy that implies an undeposited raw
    # ("absentee") parent? To determine this, check if hierarchy begins with an Imaging Event that
    # is immediately followed by a Processing Event. In this case, we assume an absentee raw parent
    # should be interposed between the Imaging Event and the Processing Event.
    #
    # @return [Boolean] Media hierarchy has an undeposited absentee raw parent media or not
    #
    def has_absentee_parent
      @has_absentee_parent ||= begin
        all_parent_works.present? &&
        all_parent_works.count >= 2 &&
        all_parent_works[0]&.has_model&.first == "ImagingEvent" &&
        all_parent_works[1]&.has_model&.first == "ProcessingEvent"
      end
    end

    #
    # Does this Media work have immediate "children" Media downstream in the hierarchy?
    #
    # @return [Boolean] Whether or not Media has any immediate child Media works
    #
    def has_child_media?
      child_media.present?
    end

    #
    # Can the imaging event for this Media be edited from this Media? Inverse of whether parent exists.
    #
    # @return [Boolean] Imaging Event can be edited from this Media or not
    #
    def imaging_event_editable?
      !parent_media.present?
    end

    #
    # Is FileSet file present and has it finished uploaded and processing?
    #
    # @return [Boolean] Whether or not FileSet file is finished uploading and ingesting
    #
    def is_file_uploaded?
      if !representative_presenter.present? && @file_status != "added" && @file_status != "updated"
        is_uploaded = false
      else
        is_uploaded = true
      end
      return is_uploaded
    end

    #
    # Is this Media work raw - has only an Imaging Event and no parents - or is it instead derived
    # from some other Media?
    #
    # @return [String] Derived or Raw label for Media
    #
    def raw_or_derived
      ( parent_media.present? || processing_events_data.present? ) ? "Derived" : "Raw"
    end

    def top_parent_media_raw_or_derived
      return nil unless top_parent_media.present?
      has_absentee_parent ? "Derived" : "Raw"
    end

    ### METHODS TO FIND SOLR DOCUMENTS FOR NON-MEDIA RELATED WORKS ###

    #
    # Physical object document (Biological Specimen Object or Cultural Heritage Object)
    #
    # @return [SolrDocument, nil] Physical object document or nil if no object
    #
    def physical_object
      return nil if !physical_object_id.present?
      @physical_object ||= begin
        begin
          doc = ::SolrDocument.find(physical_object_id)
        rescue Blacklight::Exceptions::RecordNotFound
          raise "Error loading physical object associated with media, physical object returned Blacklight::Exceptions::RecordNotFound"
        end
        if doc.human_readable_type == physical_object_type
          doc
        else
          raise "Error loading physical object associated with media, physical object is wrong type"
        end
      end
    end

    #
    # Imaging Event document
    #
    # @return [SolrDocument, nil] Imaging Event document or nil if no imaging event
    #
    def imaging_event
      return nil if !imaging_event_id.present?
      @imaging_event ||= begin
        doc = ::SolrDocument.find(imaging_event_id)
      rescue Blacklight::Exceptions::RecordNotFound
        raise "Error loading imaging event associated with media, imaging event returned Blacklight::Exceptions::RecordNotFound"
      end
    end

    #
    # Device document
    #
    # @return [SolrDocument, nil] Device document or nil if no device
    #
    def device
      return nil if !imaging_event.device_id.present?
      @device ||= begin
        doc = ::SolrDocument.find(imaging_event.device_id)
      rescue Blacklight::Exceptions::RecordNotFound
        raise "Error loading device associated with media, device returned Blacklight::Exceptions::RecordNotFound"
      end
    end

    ### VIEW PRESENTATION METHODS ###

    #
    # Long link name label string: "$ModelName $ID: $Title"
    #
    # @param [MediaPresenter, SolrDocument, Hash] obj Object with model, ID, and title properties
    #
    # @return [String] Long link name label string
    #
    def link_name_long_from_object(obj)
      if obj.is_a? MediaPresenter
        "#{obj.model.model_name.to_s} #{obj.id}: #{obj.to_s}"
      elsif obj.is_a? SolrDocument
        "#{obj.to_model.model_name.to_s} #{obj.id}: #{obj.to_s}"
      else
        "#{obj["has_model_ssim"]&.first} #{obj["id"]}: #{obj["title_tesim"]&.first}".strip
      end
    end

    def permission_badge
      permission_badge_class.new(solr_document.publication_status).render
    end

    def permission_badge_class
      Morphosource::PublicationBadge
    end

    #
    # Description string label for Media permission settings
    #
    # @return [String] Description string label for Media permission settings
    #
    def agreement_description
      "#{morphosource_use_agreement_type&.first.to_s} (#{permits_commercial_use&.first.to_s}, #{required_archival_of_published_derivatives&.first.to_s}, #{permits_3d_use&.first.to_s})".titleize.sub('3 D', '3D')
    end

    ### SHOWCASE VIEW PARTIALS ###

    def showcase_work_title_partial
      'showcase_work_title'
    end

    def showcase_show_actions_partial
      'showcase_show_actions'
    end

    def showcase_general_details_partial
      'showcase_general_details'
    end

    def showcase_file_object_details_partial
      'showcase_file_object_details'
    end

    def showcase_image_acquisition_partial
      'showcase_image_acquisition'
    end

    def showcase_image_acquisition_details_partial
      'showcase_image_acquisition_details'
    end

    def showcase_image_acquisition_details_processing_partial
      'showcase_image_acquisition_details_processing'
    end

    def showcase_ownership_and_permissions_partial
      'showcase_ownership_and_permissions'
    end

    def showcase_identifiers_and_external_links_partial
      'showcase_identifiers_and_external_links'
    end

    def showcase_viewer_partial
      'showcase_viewer'
    end

    def showcase_media_items_partial
      'showcase_media_items'
    end

    def showcase_media_items_member_partial
      'showcase_media_items_member'
    end

    def showcase_processing_activites_member_partial
      'showcase_processing_activites_member'
    end

    def showcase_collections_partial
      '/hyrax/media/showcase_collections'
    end

    def showcase_tags_partial
      '/hyrax/media/showcase_tags'
    end

    def showcase_citation_and_download_partial
      '/hyrax/physical_objects/showcase_citation_and_download'
    end

    private
      #
      # Get URL for uploaded attachment file field, by default for this Media work but can use others.
      #
      # @param [String] field Attachment file field
      # @param [String] work_id Work ID associated with attachment file
      #
      # @return [Array<String>] Attachment file URL if one is found
      #
      def get_attachment(field, work_id = id)
        Morphosource::AttachmentService.get(work_id, field).present? ?
          [Rails.application.routes.url_helpers.attachment_path(id: work_id, field: field)] :
          []
      end

      #
      # Factory for Media Member Presenter
      #
      # @return [MediaMemberPresenterFactory] Factory for Media Member Presenter
      #
      def member_presenter_factory
        MediaMemberPresenterFactory.new(solr_document, current_ability, request)
      end

      #
      # Do any representative FileSet presenters include a mesh presenter that current user can view?
      #
      # @return [Boolean] Whether or not members include viewable mesh presenter
      #
      def members_include_viewable_mesh?
        file_set_presenters.any? { |presenter| presenter.mesh? && current_ability.can?(:read, presenter.id) }
      end

      #
      # Do any representative FileSet presenters include a video presenter that current user can view?
      #
      # @return [Boolean] Whether or not members include viewable video presenter
      #
      def members_include_viewable_video?
        file_set_presenters.any? { |presenter| presenter.video? && current_ability.can?(:read, presenter.id) }
      end

      #
      # Do any representative FileSet presenters include a volume presenter that current user can view?
      #
      # @return [Boolean] Whether or not members include viewable volume presenter
      #
      def members_include_viewable_volume?
        file_set_presenters.any? { |presenter| presenter.volume? && current_ability.can?(:read, presenter.id) }
      end

      #
      # Process a Processing Event combined activity string into a parsed hash
      #
      # @param [String] pa_string Processing Event combined activity string
      #
      # @return [Hash] Parsed Processing Event activity hash
      #
      def processing_activity_hash(pa_string)
        # match text between 'Step: ' at beginning of line to ', Type: '
        step = /(?<=^Step: ).*?(?=, Type: )/.match(pa_string)
        # match text between ', Type: ' and ', Software: '
        type = /(?<=, Type: ).*?(?=, Software: )/.match(pa_string)
        # match text between ', Software: ' and ', Description: '
        software = /(?<=, Software: ).*?(?=, Description: )/.match(pa_string)
        # match text between ', Description: ' and the end of the line
        description = /(?<=, Description: ).*?(\z)/.match(pa_string)

        h = {}
        h["Step"] = step.nil? ? '' : step[0].strip
        h["Type"] = type.nil? ? '' : type[0].strip
        h["Software"] = software.nil? ? '' : software[0].strip
        h["Description"] = description.nil? ? '' : description[0].strip
        h
      end
  end
end
