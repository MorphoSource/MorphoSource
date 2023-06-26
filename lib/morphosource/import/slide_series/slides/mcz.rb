module Morphosource
  module Import
    module SlideSeries
      module Slides
        module Mcz
          # define organization/specific individual slide values here
          # overrides defaults defined in Morphosource::Import::SlideSeries::Slides::Slide

          # bits_per_sample
          def bits_per_sample
            @iiif_exif.dig("fields","BitsPerSample") || super
          end

          # color_space
          # See https://exiftool.org/TagNames/EXIF.html for values
          def color_space
            byebug
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

          def description
            preparations = @slide_json["http://rs.tdwg.org/dwc/terms/preparations"]
            preparations.present? ? Array(JSON.parse(preparations).map{|k,v| k.dup.concat(': ').concat(v)}.join(', ')) : super
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

          # mime_type
          def mime_type
            if file_name.present?
              Rack::Mime.mime_type(File.extname(file_name))
            else
              super
            end
          end

          # pixel_spacing
          def pixel_spacing
            if x_spacing.present? && y_spacing.present?
              Array("#{x_spacing.first} \\ #{y_spacing.first}")
            else
              super
            end
          end

          # def preview_mode
          #   ["Interactive/Embeddable"]
          # end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742"]
          def related_url
            ref = @slide_json["http://purl.org/dc/terms/identifier"]
            ref.present? ? Array(ref) : super
          end

          def remote_origin_url
            iiif_base_uri.concat("/full/max/0/default#{File.extname(file_name)}")
          end
          alias import_url remote_origin_url

          def remote_manifest_url
            iiif_base_uri.concat('/info.json')
          end

          # rights_holder
          #["Museum of Comparative Zoology, Harvard University"]
          def rights_holder
            rh = @json["rightsHolder"]
            rh.present? ? Array(rh) : super
          end

          def scanning_software
            software = @iiif_exif.dig('fields',"Software")
            software.present? ? Array(software) : super
          end

          # short_description
          #["HEC-1009 Slide A"]
          def short_description
            description = @slide_json["http://purl.org/dc/terms/description"]
            description.present? ? Array(description) : super
          end

          def slide_thumbnail_path
            iiif_base_uri.concat('/full/400,/0/default.jpg')
          end

          # title
          #["HEC-1009 Slide A [Image]"]
          def title
            short_description.present? ? Array("#{short_description.first} [Image]") : super
          end

          # unit
          # See https://exiftool.org/TagNames/EXIF.html
          def unit
            ru = @iiif_exif["ResolutionUnit"]
            ru.present? ? Array(Morphosource::ExifData::ResolutionUnitService.new.label(ru)) : super
          end

          # def visibility
          #   'open'
          # end

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
