require 'rest-client'

module Morphosource
  module Import
    module SlideSeries
      module Slides
        class Slide

        # Ex: @slide_json (https://www.gbif.org/occurrence/4003219413):
        # {"http://ns.adobe.com/xap/1.0/rights/WebStatement"=>"https://creativecommons.org/licenses/by-nc-sa/4.0/",
        # "http://rs.tdwg.org/ac/terms/variant"=>"ac:BestQuality",
        # "http://purl.org/dc/elements/1.1/format"=>"image/png",
        # "http://purl.org/dc/elements/1.1/rights"=>"https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode",
        # "http://iptc.org/std/Iptc4xmpExt/2008-02-29/WorldRegion"=>"[no higher geography data]",
        # "http://purl.org/dc/elements/1.1/type"=>"StillImage",
        # "http://purl.org/dc/terms/identifier"=>"http://mczbase.mcz.harvard.edu/media/3823260",
        # "http://rs.tdwg.org/ac/terms/associatedSpecimenReference"=>"http://mczbase.mcz.harvard.edu/guid/MCZ:SC:3793",
        # "http://purl.org/dc/terms/description"=>"MCZ_SC-3793_slide-1",
        # "http://rs.tdwg.org/ac/terms/metadataProviderLiteral"=>"Museum of Comparative Zoology, Harvard University",
        # "http://ns.adobe.com/exif/1.0/PixelXDimension"=>"154431",
        # "http://ns.adobe.com/xap/1.0/rights/UsageTerms"=>"Available under Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA) license",
        # "http://rs.tdwg.org/ac/terms/resourceCreationTechnique"=>"Sequential Section Scan",
        # "http://rs.tdwg.org/ac/terms/variantLiteral"=>"Best Quality",
        # "http://rs.tdwg.org/ac/terms/accessURI"=>"https://iiif.mcz.harvard.edu/iiif/3/3823260/full/max/0/default.png",
        # "http://rs.tdwg.org/dwc/terms/preparations"=>"{\"embedding material\":\"paraffin\",\"part_name\":\"histological serial section\",\"preserve_method\":\"histological slide\",\"section interval\":\"0\",\"section plane\":\"transverse\",\"section stain\":\"Bodian and Cresyl Violet\",\"section thickness\":\"15\"}",
        # "http://purl.org/dc/terms/title"=>"MCZ:SC:3793 Raja eglanteria",
        # "http://purl.org/dc/terms/rights"=>"http://creativecommons.org/licences/by-nc-sa/3.0/legalcode",
        # "http://rs.tdwg.org/ac/terms/metadataLanguage"=>"en",
        # "http://purl.org/dc/terms/type"=>"http://purl.org/dc/dcmitype/StillImage",
        # "http://rs.tdwg.org/ac/terms/serviceExpectation"=>"online",
        # "http://rs.tdwg.org/ac/terms/providerLiteral"=>"Museum of Comparative Zoology, Harvard University",
        # "http://rs.tdwg.org/dwc/terms/scientificName"=>"Raja eglanteria"}

          include Morphosource::Import::SlideSeries::Providers
          include Morphosource::Jsend

          ::RestClient.log = Rails.logger

          # Default values for slide object
          MEDIA_ARRAY_METHODS = %w[description identifier import_url license magnification preview_mode publisher related_url rights_holder short_description slice_thickness unit x_spacing y_spacing z_spacing]

          MEDIA_STRING_METHODS = %w[remote_origin_url visibility]

          FILE_ARRAY_METHODS = %w[aperture_value aspect_ratio bit_depth bits_per_sample byte_order capture_device channels color_format color_map color_space compression creator date_created date_modified file_size file_title file_type_extension focal_length format_label height image_type modality orientation original_checksum photometric_interpretation pixel_spacing pixel_representation pixel_spacing_calibration_type profile_name profile_version sample_rate samples_per_pixel scanning_software secondary_capture_device_manufacturer series_date shutter_speed slice_thickness spacing_between_slices well_formed valid width]

          FILE_STRING_METHODS = %w[file_name original_name]

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

          # {"http://rs.tdwg.org/dwc/terms/preparations"=>"{\"embedding material\":\"paraffin\",\"section stain\":\"Bodian and Cresyl Violet\",\"section thickness\":\"15\"}"}
          def description
            preparations = @slide_json['http://rs.tdwg.org/dwc/terms/preparations']
            preparations.present? ? Array(JSON.parse(preparations).map{|k,v| k.dup.concat(': ').concat(v)}.join(', ')) : []
          end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742"]
          def related_url
            ref = @slide_json['http://purl.org/dc/terms/identifier']
            ref.present? ? Array(ref) : []
          end

          # short_description
          #["HEC-1009 Slide A"]
          def short_description
            description = @slide_json['http://purl.org/dc/terms/description']
            description.present? ? Array(description) : []
          end

          def imaging_description
            []
          end

          def mime_type
            return '' unless file_name.present?

            Rack::Mime.mime_type(File.extname(file_name.first))
          end

          def slide_thumbnail_path
            ''
          end

          #["HEC-1009 Slide A [Image]"]
          def title
            short_description.present? ? Array("#{short_description.first} [Image]") : ['[Image]']
          end

          def json(uri)
            response = RestClient::Request.execute(method: 'get',
                                                  url: uri,
                                                  timeout: 15)
            process_json(response)
          rescue RestClient::BadRequest => e
            RestClient.log.error("Server returned #{e.message} for #{uri}")
            jsend_fail({ 'message' => e.message, 'request_url' => uri })
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

          def gather_technical_metadata
          end

          def validate_technical_metadata(metadata)
            metadata.reject!(&:blank?)
            if metadata.blank?
              raise StandardError.new "Technical metadata for slide #{short_description.first} is empty."
            end
          end

        end
      end
    end
  end
end
