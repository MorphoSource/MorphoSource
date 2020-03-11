module Morphosource
  module Works
    class FileSetCharacterizationParentUpdateService
      def self.run(file_set)
        new(file_set).update_parents
      end

      attr_accessor :file_set, :parents

      def initialize(file_set)
        @file_set = file_set
        @parents = file_set.member_of
      end

      def update_parents
        parents.each do |work|
          if work.class == Media
            imaging_event = ImagingEvent.where('member_ids_ssim' => work.id).first
          end
          update_parent(work)
          update_imaging_event(imaging_event) if imaging_event.present?
        end
      end

      def update_parent(work)
        field_map.each do |work_field, file_set_field|
          if file_set.send(file_set_field)&.first
            work.send(work_field.to_s + "=", field_transform[work_field])
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
          :slice_thickness => :slice_thickness
        }
      end

      def field_transform
        {
          :x_spacing => [file_set.pixel_spacing&.first.split("\\").last],
          :y_spacing => [file_set.pixel_spacing&.first.split("\\").first],
          :z_spacing => [file_set.spacing_between_slices&.first],
          :unit => ["Mm"],
          :slice_thickness => [file_set.slice_thickness&.first]
        }
      end

      def update_imaging_event(work)
        field_map_for_imaging_event.each do |work_field, file_set_field|
          if file_set.send(file_set_field)&.first
byebug
            work.send(work_field.to_s + "=", field_transform_for_imaging_event[work_field])
          end
        end
        work.save!
      end

      def field_map_for_imaging_event
        {
          :focal_length => :focal_length,
          :aperture_value => :aperture_value,
          :iso_speed_ratings => :iso_speed_ratings,
          :shutter_speed => :shutter_speed,

          :exposure_time => :exposure_time,
          # todo: need to determine which field(s) to map
          :pixel_spacing_calibration => :pixel_spacing_calibration_description,
          # : => :pixel_spacing_calibration_type,
          :frame_averaging => :contrast_frame_averaging,
          :projections => :images_in_acquisition,
          :voltage => :KVP,
          :power => :generator_power,
          :amperage => :x_ray_tube_current,
          # todo: need to determine which field(s) to map
          :surrounding_material => :container_component_id,
          # : => :container_component_width,
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
          :pixel_spacing_calibration =>  [file_set.pixel_spacing_calibration_description&.first],

          :frame_averaging =>  [file_set.contrast_frame_averaging&.first],
          :projections =>  [file_set.images_in_acquisition&.first],
          :voltage =>  [file_set.KVP&.first],
          :power =>  [file_set.generator_power&.first],
          :amperage =>  [file_set.x_ray_tube_current&.first],
          :surrounding_material =>  [file_set.container_component_id&.first],

          :xray_tube_type =>  [file_set.generator_id&.first],
          :detector_type =>  [file_set.detector_description&.first],
          :source_object_distance =>  [file_set.distance_source_to_patient&.first],
          :source_detector_distance =>  [file_set.distance_source_to_detector&.first],
          :target_material =>  [file_set.anode_target_material&.first],
          :rotation_number =>  [file_set.spiral_pitch_factor&.first]
        }
      end

    end
  end
end
