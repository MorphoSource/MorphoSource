module Morphosource
  module Import
    module SlideSeries
      module Slides
        class Slide

          include Morphosource::Import::SlideSeries::Providers
          include Morphosource::Jsend

          # Default values for slide object
          MEDIA_ARRAY_METHODS = %w[description fileset_accessibility identifier import_url license magnification preview_mode publisher related_url rights_holder short_description slice_thickness title unit x_spacing y_spacing z_spacing]

          MEDIA_STRING_METHODS = %w[remote_origin_url visibility]

          FILE_ARRAY_METHODS = %w[aperture_value aspect_ratio bit_depth bits_per_sample byte_order capture_device channels color_format color_map color_space compression creator date_created date_modified file_size file_title file_type_extension focal_length format_label height modality orientation original_checksum photometric_interpretation pixel_spacing pixel_representation pixel_spacing_calibration_type profile_name profile_version sample_rate samples_per_pixel scanning_software secondary_capture_device_manufacturer series_date shutter_speed slice_thickness spacing_between_slices well_formed valid width]

          FILE_STRING_METHODS = %w[file_name image_type original_name]

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

          def initialize(slide_json)
            @slide_json = slide_json
            gather_technical_metadata
          end

          def file_characterization_methods
            FILE_ARRAY_METHODS + FILE_STRING_METHODS
          end

          def device
            @device ||= Device.find(device_id)
          end

          def description
            preparations = @slide_json["http://rs.tdwg.org/dwc/terms/preparations"]
            preparations.present? ? Array(JSON.parse(preparations).map{|k,v| k.dup.concat(': ').concat(v)}.join(', ')) : []
          end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742"]
          def related_url
            ref = @slide_json["http://purl.org/dc/terms/identifier"]
            ref.present? ? Array(ref) : []
          end

          # short_description
          #["HEC-1009 Slide A"]
          def short_description
            description = @slide_json["http://purl.org/dc/terms/description"]
            description.present? ? Array(description) : []
          end

          def imaging_description
            []
          end

          def mime_type
            return '' unless file_name.present?

            Rack::Mime.mime_type(File.extname(file_name))
          end

          def slide_thumbnail_path
            ""
          end

          def crc32
            Array(ZipTricks::StreamCRC32.from_io(URI.parse(import_url).open))
          end

          def fileset_accessibility
            provider['fileset_accessibility']
          end

          #["HEC-1009 Slide A [Image]"]
          def title
            short_description.present? ? Array("#{short_description.first} [Image]") : [["[Image]"]]
          end

          def json(uri)
            response = RestClient::Request.execute(method: 'get',
                                                  url: uri,
                                                  timeout: 15)
            process_json(response)
          rescue StandardError => e
            RestClient.log.error("Server returned #{e.message} for #{uri}")
            jsend_error(e)
          end

          def process_json(response)
            return jsend_fail("Response code: #{response.code}") unless response.code == 200

            data = JSON.parse(response.body)
            jsend_success(data)
          rescue  StandardError => e
            jsend_error(e, 'Response.body parsing failed.')
          end

          def validate_technical_metadata(metadata)
            Array(metadata).each do |m|
              if m.empty?
                raise StandardError.new "Technical metadata for slide #{short_description.first} is empty."
              end
            end
          end

        end
      end
    end
  end
end
