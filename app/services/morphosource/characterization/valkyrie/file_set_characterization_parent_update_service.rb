# frozen_string_literal: true
module Morphosource
  module Characterization
    module Valkyrie
      class FileSetCharacterizationParentUpdateService
        def self.run(file_metadata)
          new(file_metadata).update_parents
        end

        attr_accessor :file_metadata, :file_set, :parents, :field_for_number_of_images, :value_for_number_of_images

        def initialize(file_metadata)
          @file_metadata = file_metadata
          @file_set = Hyrax.query_service.find_by(id: file_metadata.file_set_id)
          @parents = file_set.member_of
        end

        def is_dicom?
          extension = file_metadata.file_type_extension&.first
          return false unless extension.present?
          extension.downcase == 'dcm'
        end

        def update_parents
          parents.each do |work|
            # Handle Media works
            if work.class == Media || work.is_a?(Media)
              update_parent(work)

              # Find associated ImagingEvent
              imaging_event = find_imaging_event_for_media(work)
              update_imaging_event(imaging_event) if imaging_event.present?
            end
          end
        end

        # todovalk imagine events are AF works for now, but eventually will need to be updated to save as Valkyrie objects
        def find_imaging_event_for_media(media_work)
          ImagingEvent.where('member_ids_ssim' => work.id).first
        end

        def update_parent(work)
          if is_dicom?
            @field_for_number_of_images = :contents_accepted_file_count
            @value_for_number_of_images = file_metadata.contents_accepted_file_count&.first
          else
            @field_for_number_of_images = :number_of_series_related_instances
            @value_for_number_of_images = file_metadata.number_of_series_related_instances&.first
          end

          field_map.each do |work_field, file_metadata_field|
            field_value_found = file_metadata.send(file_metadata_field)&.first
            if field_value_found
              transformed_value = field_transform[work_field]
              work.send("#{work_field}=", transformed_value)
            end
          end

          # todovalk Media are AF works for now, but eventually will need to be updated to save as Valkyrie objects
          work.save!
        end

        def field_map
          {
            x_spacing: :pixel_spacing,
            y_spacing: :pixel_spacing,
            z_spacing: :spacing_between_slices,
            unit: :pixel_spacing,
            slice_thickness: :slice_thickness,
            number_of_images_in_set: @field_for_number_of_images
          }
        end

        def field_transform
          {
            x_spacing: [file_metadata.pixel_spacing&.first&.split("\\")&.last],
            y_spacing: [file_metadata.pixel_spacing&.first&.split("\\")&.first],
            z_spacing: [file_metadata.spacing_between_slices&.first],
            unit: ["Mm"],
            slice_thickness: [file_metadata.slice_thickness&.first],
            number_of_images_in_set: @value_for_number_of_images.to_s
          }
        end

        def update_imaging_event(work)
          field_map_for_imaging_event.each do |work_field, file_metadata_field|
            field_value_found = file_metadata.send(file_metadata_field)&.first
            if field_value_found
              transformed_value = field_transform_for_imaging_event[work_field]
              work.send("#{work_field}=", transformed_value)
            end
          end

          work.save!
        end

        def field_map_for_imaging_event
          {
            focal_length: :focal_length,
            aperture_value: :aperture_value,
            iso_speed_ratings: :iso_speed_ratings,
            shutter_speed: :shutter_speed,
            exposure_time: :exposure_time,
            pixel_spacing_calibration: :pixel_spacing_calibration_type,
            frame_averaging: :contrast_frame_averaging,
            projections: :images_in_acquisition,
            voltage: :KVP,
            power: :generator_power,
            amperage: :x_ray_tube_current,
            surrounding_material: :container_description,
            xray_tube_type: :generator_id,
            detector_type: :detector_description,
            source_object_distance: :distance_source_to_patient,
            source_detector_distance: :distance_source_to_detector,
            target_material: :anode_target_material,
            rotation_number: :spiral_pitch_factor
          }
        end

        def field_transform_for_imaging_event
          {
            focal_length: [file_metadata.focal_length&.first],
            aperture_value: [file_metadata.aperture_value&.first],
            iso_speed_ratings: [file_metadata.iso_speed_ratings&.first],
            shutter_speed: [file_metadata.shutter_speed&.first],
            exposure_time: [file_metadata.exposure_time&.first],
            pixel_spacing_calibration: [title_case(file_metadata.pixel_spacing_calibration_type&.first)],
            frame_averaging: [file_metadata.contrast_frame_averaging&.first],
            projections: [file_metadata.images_in_acquisition&.first],
            voltage: [file_metadata.KVP&.first],
            power: [file_metadata.generator_power&.first],
            amperage: [file_metadata.x_ray_tube_current&.first],
            surrounding_material: [file_metadata.container_description&.first],
            xray_tube_type: [file_metadata.generator_id&.first],
            detector_type: [file_metadata.detector_description&.first],
            source_object_distance: [file_metadata.distance_source_to_patient&.first],
            source_detector_distance: [file_metadata.distance_source_to_detector&.first],
            target_material: [file_metadata.anode_target_material&.first],
            rotation_number: [file_metadata.spiral_pitch_factor&.first]
          }
        end

        def title_case(value)
          return nil unless value.present?
          value.titleize
        end
      end
    end
  end
end
