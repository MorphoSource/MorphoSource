require 'active_support/core_ext/numeric/conversions'
# Generated via
#  `rails generate hyrax:work Media`
module Hyrax
  class MediaPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods
    include MorphosourceHelper
    include MediaFinderHelper

    delegate :agreement_uri, :cite_as, :funding, :map_type, :media_type, :orientation, :part, :rights_holder, :scale_bar, :series_type, :short_description, :description, :side, :unit, :x_spacing, :y_spacing, :z_spacing, :slice_thickness, :number_of_images_in_set, :identifier, :related_url, :point_count, :fileset_visibility, :fileset_accessibility, :preview_mode, to: :solr_document

    attr_accessor :file_status, :physical_object_type, :idigbio_uuid, :vouchered,
      :physical_object_title, :physical_object_link, :physical_object_id,
      :device_and_facility, :device_link, :device, :device_manufacturer, :device_description,
      :device_organization_institution,
      :other_details, :imaging_event_creator, :imaging_event_date_created, :imaging_event_software,
      :imaging_event_description, :imaging_event_description_attachment, :imaging_event_modality,
      :parent_media_id_list, :child_media_id_list, :parent_media_members,
      :sibling_media_id_list, :parent_media_count, :direct_parent_members, :this_media_member,
      :this_media_and_parents_id_list, :this_media_and_parents_members,
      :processing_events, :processing_events_data, :processing_event_count, :this_media_processing_event,
      :processing_activity_count, :data_managed_by, :download_permission, :ark, :doi, :lens,
      :raw_or_derived, :is_absentee_parent,
      :imaging_event, :imaging_event_exist, :imaging_event_editable, :direct_parent_first_member,
      :direct_parent_members_raw_or_derived,
      :file_size, :mime_type, :this_media_type, :file_set_list,
      # Permissions
      :permits_commercial_use, :permits_3d_use, :required_archival_of_published_derivatives,
      :morphosource_use_agreement_type, :download_reviewer,
      # BSO fields
      :collection_code, :institution_code, :catalog_number, :occurrence_id, :idigbio_uuid,
      :user_taxonomies, :canonical_taxonomy_object, :trusted_taxonomies,
      # CHO fields
      :cho_type, :material, :short_title,
      # mesh specific
      :point_count,
      :face_count,
      :color_format,
      :normals_format,
      :has_uv_space,
      :vertex_color,
      :bounding_box_dimensions,
      :centroid_location,
      # XRAY modality fields
      :exposure_time,
      :flux_normalization,
      :pixel_spacing_calibration,
      :shading_correction,
      :filter,
      :frame_averaging,
      :projections,
      :voltage,
      :power,
      :amperage,
      :surrounding_material,
      :xray_tube_type,
      :target_type,
      :detector_type,
      :detector_configuration,
      :source_object_distance,
      :source_detector_distance,
      :target_material,
      :rotation_number,
      :phase_contrast,
      :optical_magnification,
      :acquisition_type,
      # CT imagestack fields
      :image_width,
      :image_height,
      :color_space,
      :color_depth,
      :compression

    def universal_viewer?
      viewer_ready = representative_id.present? &&
        representative_presenter.present? &&
        Hyrax.config.iiif_image_server?  &&
        universal_viewable_ready?
      return viewer_ready
    end

    def is_file_uploaded?
      if !@file_set_list.present? && @file_status != "added" && @file_status != "updated"
        is_uploaded = false
      else
        is_uploaded = true
      end
      return is_uploaded
    end

    def universal_viewable_ready?
      return false unless representative_presenter.present?
      viewable = 
        ( representative_presenter.image? || representative_presenter.mesh? || representative_presenter.volume? ) &&
        ( members_include_viewable_image? || members_include_viewable_mesh? || members_include_viewable_volume? )
      return viewable
    end

    def source_of_record
      if @idigbio_uuid.present?
        'iDigBio'
      else
        ''
      end
    end

    def is_published?
      @download_permission.include?('Publish')
    end

    def has_child_media?
      @child_media_id_list.any?
    end

    def has_processing_events?
      @processing_events.present?
    end

    def has_imaging_events?
      @imaging_event.present?
    end

    def imaging_event_editable?
      imaging_event_editable == true
    end

    def preview_in_3D?
      preview_mode&.first == "Interactive/Embeddable"
    end

    def round_it(string_value)
      if is_number_with_decimal?(string_value)
        string_value.to_f.round(3).to_s
      else
        string_value
      end
    end

    def get_showcase_data
      media = Media.where('id' => solr_document.id).first
      # todo: need to get the user name (and a link to user) from the email address
      @data_managed_by = solr_document.depositor

      @download_permission = get_download_permission(media)

      @permits_commercial_use = Morphosource::CommercialUseTypesService.new.label(media.permits_commercial_use.first) if media.permits_commercial_use.present?
      @permits_3d_use = Morphosource::ThreeDUseTypesService.new.label(media.permits_3d_use.first) if media.permits_3d_use.present?
      @required_archival_of_published_derivatives = Morphosource::RequiredArchivalOfPublishedDerivativesTypesService.new.label(media.required_archival_of_published_derivatives.first) if media.required_archival_of_published_derivatives.present?
      @morphosource_use_agreement_type = Morphosource::MorphosourceUseAgreementTypesService.new.label(media.morphosource_use_agreement_type.first) if media.morphosource_use_agreement_type.present?
      @download_reviewer = media.download_reviewer.first

      @ark = media.ark
      @doi = media.doi

      # get file characterization metadata, and add up the values (face count, point count, file size, etc)
      @this_media_type = media.media_type.first
      @mime_type = []
      @file_size = 0
      @point_count = 0
      @face_count = 0
      @color_format = []
      @normals_format = []
      @has_uv_space = []
      @vertex_color = []
      @bounding_box_dimensions = []
      @centroid_location = []
      @color_space = []
      @image_width = []
      @image_height = []
      @compression = []
      @color_depth = []
      @file_status = ""
      temp = ""
      contents_mime_type = ""
      @file_set_list = media.file_set_ids
      @file_set_list.each do |id|
        file_set = ::FileSet.find(id)
        # since mime type can me a zip, first try to get the actual content mime type if exists
        # if content mime type does not exist, use the mime type
        if file_set.contents_mime_type.first.present?
          contents_mime_type = file_set.contents_mime_type.first
        elsif file_set.mime_type.present?
          contents_mime_type = file_set.mime_type
        else
          contents_mime_type = 'unknown'
          # todo: might need to check why some image format (e.g. ARW) is not returning a mime type
          # could be related to the conflict in the FITS output xml:
          #  <identification status="CONFLICT">
          #    <identity format="ARW EXIF" mimetype="image/x-sony-arw" toolname="FITS" toolversion="1.5.0">
          #      <tool toolname="Exiftool" toolversion="11.54" />
          #    </identity>
          #    <identity format="Tagged Image File Format" mimetype="image/tiff" toolname="FITS" toolversion="1.5.0">
          #      <tool toolname="ffident" toolversion="0.2" />
          #      <tool toolname="Tika" toolversion="1.21" />
          #    </identity>
          #  </identification>
        end
        @mime_type << contents_mime_type
        @file_size += file_set.file_size.first.to_i if file_set.file_size.present?
        if @this_media_type == "Mesh"
          @point_count += file_set.point_count.first.to_i if file_set.point_count.present?
          @face_count += file_set.face_count.first.to_i  if file_set.face_count.present?
          @color_format << file_set.color_format.first.to_s if file_set.color_format.present?
          @normals_format << file_set.normals_format.first.to_s if file_set.normals_format.present?
          @has_uv_space << file_set.has_uv_space.first.to_s if file_set.has_uv_space.present?
          @vertex_color << file_set.vertex_color.first.to_s if file_set.vertex_color.present?
          if (file_set.bounding_box_x.present? and file_set.bounding_box_y.present? and file_set.bounding_box_z.present?)
            temp = round_it(file_set.bounding_box_x.first) + ', ' + round_it(file_set.bounding_box_y.first) + ', ' + round_it(file_set.bounding_box_z.first)
            @bounding_box_dimensions << temp
          end
          if (file_set.centroid_x.present? and file_set.centroid_y.present? and file_set.centroid_z.present?)
            temp = round_it(file_set.centroid_x.first) + ', ' + round_it(file_set.centroid_y.first) + ', ' + round_it(file_set.centroid_z.first)
            @centroid_location << temp
          end
        elsif @this_media_type.match(/image/i)
          @image_width << file_set.width.first.to_s if file_set.width.present?
          @image_height << file_set.height.first.to_s if file_set.height.present?
          @color_space << file_set.color_space.first.to_s if file_set.color_space.present?
          @compression << file_set.compression.first.to_s if file_set.compression.present?
          # color_depth value comes from different attributes, depending on the file type
          # for multiple values e.g. '8 8 8' , concat them with '/'
          if contents_mime_type.match(/(dcm|dicom)/i)
            @color_depth << file_set.bits_allocated.first.to_s if file_set.bits_allocated.present?
          else #if contents_mime_type.match(/(jp?eg|ti?ff)/)
            temp = file_set.bits_per_sample.first.to_s if file_set.bits_per_sample.present?
            @color_depth << temp.gsub(/\s/, '/')
          end

        end

      end # file_set_list loop

      @mime_type = @mime_type.uniq.join(", ")
      if @file_size == 0
        @file_size = ""
      else
        @file_size = @file_size.to_s(:delimited) + " bytes" # todo: convert to pretty format later
      end
      if @point_count == 0
        @point_count = ""
      else
        @point_count = @point_count.to_s(:delimited)
      end
      if @face_count == 0
        @face_count = ""
      else
        @face_count = @face_count.to_s(:delimited)
      end

      # Get parent medias (all)
      # add current media id, then add child media ids.
      # currently add up to 5 levels in the tree.  Later we should store the child medias in the work
      # so there is no need to traverse the tree
      @parent_media_id_list = parent_media_ids(media, 5, []).flatten.uniq
      @parent_media_count = @parent_media_id_list.length.to_s
      @child_media_id_list = child_media_ids(media, 5, []).flatten.uniq
      @sibling_media_id_list = sibling_media_ids(media, []).flatten.uniq
      @parent_media_members = member_presenters_for(@parent_media_id_list.reverse())

      # get the top parent
      direct_parent_id = top_parent_media_id(media)
      #direct_parent_id_list = parent_media_ids(media, 1, []).flatten.uniq
      direct_parent_id_list = []
      if direct_parent_id.present?
        direct_parent_id_list << direct_parent_id
      end

      @is_absentee_parent = false

      this_media_list = [] << solr_document.id
      @this_media_member = member_presenters_for(this_media_list).first

      # get members for this media combined with parents, ordered in reverse
      @this_media_and_parents_id_list = parent_media_id_list << solr_document.id
      @this_media_and_parents_members = parent_media_members << this_media_member

      # get processing event:  media < processing_event
      # then get processing event data: activity items, child/parent IDs and member presenters
      @processing_events = ProcessingEvent.where('member_ids_ssim' => this_media_and_parents_id_list)
      processing_event_ids = []
      @processing_events_data = []
      processing_events.each do |pe|
        processing_event_ids << pe.id

        processing_activity_items = []
        pe.processing_activity.each do |processing_activity|
          processing_activity_items << Hash[processing_activity.split(/\s*,\s*/).map {|el| el.split ': '}]
        end
        processing_activity_items.sort_by! { |hsh| hsh["Step"] }

        parent_ids = []
        parent_ids = pe.in_work_ids.select { |m_id| parent_media_id_list.include? m_id }

        if Morphosource::AttachmentService.get(pe.id, 'pe_description').present?
          pe_description_attachment = 
            [Rails.application.routes.url_helpers.attachment_path(id: pe.id, field: 'pe_description')]
        else
          pe_description_attachment = []
        end

        @processing_events_data << {
          :id => pe.id,
          :processing_activity_items => processing_activity_items,
          :child_ids => pe.member_ids,
          :child_members => this_media_and_parents_members.select { |m| pe.member_ids.include? m.id },
          :parent_ids => parent_ids,
          :parent_members => this_media_and_parents_members.select { |m| parent_ids.include? m.id },
          :creator => pe.creator,
          :date_created => pe.date_created,
          :software => pe.software,
          :description => pe.description,
          :description_attachment => pe_description_attachment
        }
      end

      @processing_event_count = processing_events.count
      @processing_activity_count = processing_events_data
        .map { |pe| pe[:processing_activity_items].length}
        .inject(0) { |sum, x| sum + x }
      @this_media_processing_event = processing_events
        .find { |pe| pe.member_ids.include? solr_document.id }

      if direct_parent_id_list.length > 0
        # If a media has a parent work and is derived, then that media’s raw ancestor media work
        # (whether parent, grandparent, etc) should be connected to an IE from which metadata should be derived.
        @direct_parent_members = member_presenters_for(direct_parent_id_list)
        target_media = Media.where('id' => direct_parent_id).first
        @imaging_event_editable = false
        @direct_parent_first_member = @direct_parent_members.first
        @raw_or_derived = "Derived"
        @direct_parent_members_raw_or_derived = "Raw"
      else
        @imaging_event_editable = true
        # check if this is a Derived media with "absentee parent" by checking if PE exists
        if @processing_event_count > 0
          @is_absentee_parent = true
          @direct_parent_members = member_presenters_for(this_media_list)
          target_media = media
          @raw_or_derived = "Derived"
          @direct_parent_members_raw_or_derived = "Derived"
        else
          # If a media is raw and has no parent media work, then get data from current media via the IE.
          @direct_parent_members = member_presenters_for(this_media_list)
          target_media = media
          @raw_or_derived = "Raw"
          @direct_parent_members_raw_or_derived = "Raw"
        end
      end
      #Rails.logger.info("(010) in MediaPresenter: #{@raw_or_derived.inspect} ")
      #Rails.logger.info("(010) in MediaPresenter: #{@direct_parent_members_raw_or_derived.inspect} ")

      # Get the physical object type from:
      # Media < IE < PO
      # or
      # media < PE < IE < PO (for media with absentee parent)
      if @is_absentee_parent == true
        @imaging_event = ImagingEvent.where('member_ids_ssim' => processing_event_ids.first).first
      else
        # It's still possible to have an ImagingEvent through the ProcessingEvent, but we prioritize
        # those directly on the target media
        @imaging_event = ImagingEvent.where('member_ids_ssim' => target_media.id).first
        if @imaging_event.nil? && (@processing_event_count > 0)
          @imaging_event = ImagingEvent.where('member_ids_ssim' => processing_event_ids.first).first
        end
      end

      if @imaging_event.present?
        imaging_event_exist = true
        biological_specimen = BiologicalSpecimen.where('member_ids_ssim' => @imaging_event.id).first
        cultural_heritage_object = CulturalHeritageObject.where('member_ids_ssim' => @imaging_event.id).first

        if biological_specimen.present?
          @physical_object_title = biological_specimen.title.first
          @physical_object_id = biological_specimen.id
          @physical_object_link = "/concern/biological_specimens/" + @physical_object_id
          @idigbio_uuid = biological_specimen.idigbio_uuid
          @vouchered = biological_specimen.vouchered
          @physical_object_type = biological_specimen.human_readable_type
          @institution_code = biological_specimen.institution_code
          @collection_code = biological_specimen.collection_code
          @catalog_number = biological_specimen.catalog_number
          @occurrence_id = biological_specimen.occurrence_id
          @user_taxonomies = biological_specimen.user_taxonomies
          @canonical_taxonomy_object = biological_specimen.canonical_taxonomy_object
          @trusted_taxonomies = biological_specimen.trusted_taxonomies
          @idigbio_uuid = biological_specimen.idigbio_uuid
        elsif cultural_heritage_object.present?
          @physical_object_title = cultural_heritage_object.title.first
          @physical_object_id = cultural_heritage_object.id
          @physical_object_link = "/concern/cultural_heritage_objects/" + @physical_object_id
          @vouchered = cultural_heritage_object.vouchered
          @physical_object_type = cultural_heritage_object.human_readable_type
          @institution_code = cultural_heritage_object.institution_code
          @collection_code = cultural_heritage_object.collection_code
          @catalog_number = cultural_heritage_object.catalog_number
          @cho_type = cultural_heritage_object.cho_type
          @material = cultural_heritage_object.material
          @short_title = cultural_heritage_object.short_title
        end

        # get device from imaging event
        device = Device.where('member_ids_ssim' => @imaging_event.id).first
        if device.present?
          @device = device.title.first
          @device_organization_institution = organization_institution(device.id)
          @device_and_facility = @device
          @device_and_facility += ", " + @device_organization_institution if @device_organization_institution.present?
          @device_link = "/concern/devices/" + device.id
          @device_manufacturer = device.creator
          @device_description = device.description
        end

        # get imaging event details
        @imaging_event_modality = @imaging_event.ie_modality.first
        if @imaging_event_modality == "Photogrammetry" or
            @imaging_event_modality == "Photography"
          @lens = ""
          @lens << @imaging_event.lens_make.first if @imaging_event.lens_make.present?
          @lens << " " + @imaging_event.lens_model.first if @imaging_event.lens_model.present?
          @other_details = []
          @other_details << @imaging_event.focal_length_type.first + " focal length" if @imaging_event.focal_length_type.present?
          @other_details << @imaging_event.light_source.first + " light" if @imaging_event.light_source.present?
          @other_details << @imaging_event.background_removal.first if @imaging_event.background_removal.present?
          @other_details = @other_details.join(' / ')
        elsif @imaging_event_modality.upcase.include? "XRAY"
          @exposure_time = @imaging_event.exposure_time.first
          @flux_normalization = @imaging_event.flux_normalization.first
          @pixel_spacing_calibration = @imaging_event.pixel_spacing_calibration.first
          @shading_correction = @imaging_event.shading_correction.first
          @filter = @imaging_event.ie_filter.first
          @frame_averaging = @imaging_event.frame_averaging.first
          @projections = @imaging_event.projections.first
          @voltage = @imaging_event.voltage.first
          @power = @imaging_event.power.first
          @amperage = @imaging_event.amperage.first
          @surrounding_material = @imaging_event.surrounding_material.first
          @xray_tube_type = @imaging_event.xray_tube_type.first
          @target_type = @imaging_event.target_type.first
          @detector_type = @imaging_event.detector_type.first
          @detector_configuration = @imaging_event.detector_configuration.first
          @source_object_distance = @imaging_event.source_object_distance.first
          @source_detector_distance = @imaging_event.source_detector_distance.first
          @target_material = @imaging_event.target_material.first
          @rotation_number = @imaging_event.rotation_number.first
          @phase_contrast = @imaging_event.phase_contrast.first
          @optical_magnification = @imaging_event.optical_magnification.first
          @acquisition_type = @imaging_event.acquisition_type.first

        end
        @imaging_event_creator = @imaging_event.creator
        @imaging_event_date_created = @imaging_event.date_created
        @imaging_event_software = @imaging_event.software
        @imaging_event_description = @imaging_event.description
        if Morphosource::AttachmentService.get(@imaging_event.id, 'ie_description').present?
          @imaging_event_description_attachment = 
            [Rails.application.routes.url_helpers.attachment_path(id: @imaging_event.id, field: 'ie_description')]
        else
          @imaging_event_description_attachment = []
        end
      else
        imaging_event_exist = false
      end # end if imaging_event present?

    end

    # this method is cloned from list_of_item_ids_to_display (for defaut view),
    # and override the method in presenter_methods
    # to get a list of media images for MEDIA showpage
    def list_of_item_ids_to_display_for_showpage
      media_ids = []
      media_ids << @parent_media_id_list << @child_media_id_list << @sibling_media_id_list
      media_ids.flatten
    end

    # this method is cloned from list_of_item_ids_to_display
    # and override the method in presenter_methods
    # to get a list of media images for the current media work only
    def list_of_item_ids_to_display_for_current_media
      media_ids = []
      media_ids << @parent_media_id_list << @child_media_id_list << @sibling_media_id_list
      media_ids.flatten
    end

    def in_collection_badge
      # override the method in presents_attributes, passing the vouchered retrieved from get_showcase_data
      in_collection_badge_class.new(@vouchered).render
    end

    def supplied_record_badge
      # override the method in presents_attributes, passing the idigbio_uuid retrieved from get_showcase_data
      supplied_record_badge_class.new(@idigbio_uuid).render
    end

    # methods for showcase partials
    def showcase_work_title_partial
      'showcase_work_title'
    end

    def showcase_show_actions_partial
      'showcase_show_actions'
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

    def showcase_direct_parents_member_partial
      'showcase_direct_parents_member'
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
      '/hyrax/physical_objects/showcase_collections'
    end

    def showcase_tags_partial
      '/hyrax/media/showcase_tags'
    end

    def showcase_citation_and_download_partial
      '/hyrax/physical_objects/showcase_citation_and_download'
    end

    private
      def member_presenter_factory
        MediaMemberPresenterFactory.new(solr_document, current_ability, request)
      end

      def members_include_viewable_mesh?
        file_set_presenters.any? { |presenter| presenter.mesh? && current_ability.can?(:read, presenter.id) }
      end

      def members_include_viewable_volume?
        file_set_presenters.any? { |presenter| presenter.volume? && current_ability.can?(:read, presenter.id) }
      end

      def get_download_permission(media)
        if media.embargo.present? && media.embargo.visibility_during_embargo.present?
          display_value = "Embargo"
        elsif media.lease.present? && media.lease.visibility_during_lease.present?
          display_value = "Lease"
        else
          case media.fileset_accessibility.first
          when 'open'
            display_value = "Publish with Open Download"
          when 'restricted_download'
            display_value = "Publish with Restricted Download"
          when 'preview_only'
            display_value = "Publish with No Download"
          when 'hidden'
            display_value = "Publish with Hidden File"
          when 'private'
            display_value = "Private"
          end
        end
        display_value
      end

  end
end
