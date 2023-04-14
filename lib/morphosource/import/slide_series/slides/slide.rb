module Morphosource
  module Import
    module SlideSeries
      module Slides
        class Slide

          # Default values for slide object
          MEDIA_ARRAY_METHODS = %w[description fileset_accessibility identifier import_url license magnification publisher related_url rights_holder short_description slice_thickness title unit x_spacing y_spacing z_spacing]

          MEDIA_STRING_METHODS = %w[visibility]

          FILE_ARRAY_METHODS = %w[aperture_value aspect_ratio bit_depth bits_per_sample byte_order capture_device channels color_format color_map color_space compression crc32 creator date_created date_modified file_name file_size file_title file_type_extension focal_length format_label height modality orientation original_checksum photometric_interpretation pixel_spacing pixel_representation pixel_spacing_calibration_type profile_name profile_version sample_rate samples_per_pixel scanning_software secondary_capture_device_manufacturer series_date shutter_speed slice_thickness spacing_between_slices well_formed valid width]

          FILE_STRING_METHODS = %w[image_type mime_type original_name]

          (MEDIA_ARRAY_METHODS + FILE_ARRAY_METHODS).each do |method|
            define_method(method) do
              []
            end
          end

          (MEDIA_STRING_METHODS + FILE_STRING_METHODS).each do |method|
            define_method(method) do
              ""
            end
          end

          def initialize(json, slide_json)
            @json = json
            @slide_json = slide_json
            gather_metadata
          end

          def file_characterization_methods
            FILE_ARRAY_METHODS + FILE_STRING_METHODS
          end

          def device
            @device ||= Device.find(device_id)
          end

          def json(uri)
            JSON.parse((RestClient.get uri).body)
          end

          def slide_thumbnail_path
            ""
          end
        end
      end
    end
  end
end
