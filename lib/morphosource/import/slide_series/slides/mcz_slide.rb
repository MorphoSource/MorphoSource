module Morphosource
  module Import
    module SlideSeries
      module Slides
        class MczSlide < Morphosource::Import::SlideSeries::Slides::Slide

          def device
            iiif_exif.dig('fields','Model')
          end

          def gather_technical_metadata
            @iiif_json = iiif_json
            @iiif_exif = iiif_exif
            validate_technical_metadata([@iiif_json, @iiif_exif])
          end

          def iiif_base_uri
            @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split('/full/').first
          end

          def iiif_json
            @iiif_json ||= get_iiif_json
          end

          def get_iiif_json
            result = json("#{iiif_base_uri}/info.json")
            if result[:status] == :success
              result[:data]
            else
              {}
            end
          end

          def iiif_exif
            iiif_json["exif"] || {}
          end

          # technical metadata values

          # bits_per_sample
          def bits_per_sample
            @iiif_exif.dig("fields","BitsPerSample") || super
          end

          # color_space
          # See https://exiftool.org/TagNames/EXIF.html for values
          def color_space
            cs = @iiif_exif.dig("fields","PhotometricInterpretation")
            cs.present? ? Array(Morphosource::ExifData::PhotometricInterpretationService.new.label(cs)) : super
          end

          # compression
          # See https://exiftool.org/TagNames/EXIF.html#Compression
          def compression
            comp = @iiif_exif.dig("fields","Compression")
            comp.present? ? Array(Morphosource::ExifData::CompressionService.new.label(comp)) : super
          end

          # file.create_date
          # date_created
          def date_created
            date = @iiif_exif.dig('fields',"DateTime")
            date.present? ? Array(Date.parse(date.split(' ').first.gsub(':','-')).strftime("%Y-%m-%d")) : super
          end

          # file_name
          def file_name
            @iiif_json["originalFilename"] || super
          end

          # file_size
          def file_size
            @iiif_json["fileSize"] || super
          end

          # height
          def height
            @iiif_json["height"]&.to_s || super
          end

          # identifier
          #["5c454d3c70aaa9064404a300"]
          def identifier
            Array(iiif_base_uri.split('/').last)
          end

          def imaging_description
            description = @iiif_exif.dig("fields","ImageDescription")
            description.present? ? Array(description) : super
          end

          # pixel_spacing
          def pixel_spacing
            if x_spacing.present? && y_spacing.present?
              Array("#{x_spacing.first} \\ #{y_spacing.first}")
            else
              super
            end
          end

          def remote_origin_url
            return super unless file_name.present?

            iiif_base_uri.concat("/full/max/0/default#{File.extname(file_name)}")
          end
          alias import_url remote_origin_url

          def remote_manifest_url
            iiif_base_uri.concat('/info.json')
          end

          def scanning_software
            software = @iiif_exif.dig('fields',"Software")
            software.present? ? Array(software) : super
          end

          def slide_thumbnail_path
            iiif_base_uri.concat('/full/400,/0/default.jpg')
          end

          # unit
          # See https://exiftool.org/TagNames/EXIF.html
          def unit
            ru = @iiif_exif["ResolutionUnit"]
            ru.present? ? Array(Morphosource::ExifData::ResolutionUnitService.new.label(ru)) : super
          end

          # width
          def width
            w = @iiif_json["width"]&.to_s
            w.present? ? w : super
          end

          # x_spacing
          def x_spacing
            denominator = @iiif_exif.dig('fields',"XResolution","denominator")&.to_f
            numerator = @iiif_exif.dig('fields',"XResolution","numerator")&.to_f
            if denominator && numerator
              Array("%f" % (denominator/numerator))
            else
              super
            end
          end

          # y_spacing
          def y_spacing
            denominator = @iiif_exif.dig('fields',"YResolution","denominator")&.to_f
            numerator = @iiif_exif.dig('fields',"YResolution","numerator")&.to_f
            if denominator && numerator
              Array("%f" % (denominator/numerator))
            else
              super
            end
          end
        end
      end
    end
  end
end
