module Morphosource
  module Works
    class FileSetCharacterizationParentUpdateService
      def self.run(file_set)
        new(file_set).update_parents
      end

      attr_accessor :file_set, :parents, :field_for_number_of_images, :value_for_number_of_images

      def initialize(file_set)
        @file_set = file_set
        @parents = file_set.member_of
      end

      def isDicom?(fs) 
        extension = fs.file_type_extension&.first
        if extension.present?
          return extension.downcase == 'dcm'
        else
          return false
        end
      end

      def update_parents
        parents.each do |work|
          if work.class == Media
            imaging_event = find_imaging_event_for_media(work)
          end
          update_parent(work)
          update_imaging_event(imaging_event) if imaging_event.present?
        end
      end

      def find_imaging_event_for_media(media_work)
        # TODO: Remove ImagingEvent from Solr query and AF fallback when all ImagingEvents have been migrated to ImagingEventResource
        ie_docs = Morphosource::SolrService.new.get_docs(
          nil,
          fq: ["member_ids_ssim:#{media_work.id}",
               "has_model_ssim:(ImagingEvent ImagingEventResource)"]
        )
        return nil unless ie_docs.present?

        ie_id = ie_docs.first['id']
        begin
          Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(ie_id))
        rescue Valkyrie::Persistence::ObjectNotFoundError
          ImagingEvent.find(ie_id)
        rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone
          nil
        end
      end

      def update_parent(work)
        if isDicom?(file_set)
          @field_for_number_of_images = :contents_accepted_file_count
          @value_for_number_of_images = file_set.contents_accepted_file_count&.first
        else
          @field_for_number_of_images = :number_of_series_related_instances
          @value_for_number_of_images = file_set.number_of_series_related_instances&.first
        end
        field_map.each do |work_field, file_set_field|
          field_value_found = file_set.send(file_set_field)&.first
          if field_value_found
            transformed_value = field_transform[work_field]
            work.send(work_field.to_s + "=", transformed_value)
          end
        end
        work.save!
      end

      def field_map
        {
          :x_spacing => :pixel_spacing,
          :y_spacing => :pixel_spacing,
          :z_spacing => :spacing_between_slices, # slice thickness and number of images in set
          :unit => :pixel_spacing,
          :slice_thickness => :slice_thickness,
          :number_of_images_in_set => @field_for_number_of_images
        }
      end

      def field_transform
        {
          :x_spacing => [file_set.pixel_spacing&.first.split("\\").last],
          :y_spacing => [file_set.pixel_spacing&.first.split("\\").first],
          :z_spacing => [file_set.spacing_between_slices&.first],
          :unit => ["Mm"],
          :slice_thickness => [file_set.slice_thickness&.first],
          :number_of_images_in_set => @value_for_number_of_images.to_s
        }
      end

      def update_imaging_event(work)
        field_map_for_imaging_event.each do |work_field, file_set_field|
          field_value_found = file_set.send(file_set_field)&.first
          if field_value_found
            transformed_value = field_transform_for_imaging_event[work_field]
            work.send(work_field.to_s + "=", transformed_value)
          end
        end
        # TODO: Remove AF branch (work.save!) when all ImagingEvents have been migrated to ImagingEventResource
        work.is_a?(Hyrax::Resource) ? work.save : work.save!
      end

      def field_map_for_imaging_event
        {
          :focal_length => :focal_length,
          :aperture_value => :aperture_value,
          :iso_speed_ratings => :iso_speed_ratings,
          :shutter_speed => :shutter_speed,
          :exposure_time => :exposure_time,
          :pixel_spacing_calibration => :pixel_spacing_calibration_type,
          :frame_averaging => :contrast_frame_averaging,
          :projections => :images_in_acquisition,
          :voltage => :KVP,
          :power => :generator_power,
          :amperage => :x_ray_tube_current,
          :surrounding_material => :container_description,
          :xray_tube_type => :generator_id,
          :detector_type => :detector_description,
          :source_object_distance => :distance_source_to_patient,
          :source_detector_distance => :distance_source_to_detector,
          :target_material => :anode_target_material,
          :rotation_number => :spiral_pitch_factor
        }
      end

      def field_transform_for_imaging_event
        {
          :focal_length =>  [file_set.focal_length&.first],
          :aperture_value => [file_set.aperture_value&.first],
          :iso_speed_ratings => [file_set.iso_speed_ratings&.first],
          :shutter_speed => [file_set.shutter_speed&.first],

          :exposure_time =>  [file_set.exposure_time&.first],
          :pixel_spacing_calibration =>  [title_case(file_set.pixel_spacing_calibration_type&.first)],
          :frame_averaging =>  [file_set.contrast_frame_averaging&.first],
          :projections =>  [file_set.images_in_acquisition&.first],
          :voltage =>  [file_set.KVP&.first],
          :power =>  [file_set.generator_power&.first],
          :amperage =>  [file_set.x_ray_tube_current&.first],
          :surrounding_material =>  [file_set.container_description&.first],
          :xray_tube_type =>  [file_set.generator_id&.first],
          :detector_type =>  [file_set.detector_description&.first],
          :source_object_distance =>  [file_set.distance_source_to_patient&.first],
          :source_detector_distance =>  [file_set.distance_source_to_detector&.first],
          :target_material =>  [file_set.anode_target_material&.first],
          :rotation_number =>  [file_set.spiral_pitch_factor&.first]
        }
      end

      def title_case(value)
        if value.present?
          return value.titleize
        else
          return nil
        end
      end

    end
  end
end
