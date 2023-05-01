module Morphosource
  module Import
    module SlideSeries
      module Slides
        module Mcz
          # define organization/specific individual slide values here
          # overrides defaults defined in Morphosource::Import::SlideSeries::Slides::Slide

          # bits_per_sample
          def bits_per_sample
            @iiif_exif&.dig("fields","BitsPerSample") || super
          end

          # color_space
          # See https://exiftool.org/TagNames/EXIF.html for values
          def color_space
            cs = @iiif_exif&.dig("fields","PhotometricInterpretation")
            cs.present? ? Array(Morphosource::ExifData::PhotometricInterpretationService.new.label(cs)) : super
          end

          # compression
          # See https://exiftool.org/TagNames/EXIF.html#Compression
          def compression
            comp = @iiif_exif&.dig("fields","Compression")
            comp.present? ? Array(Morphosource::ExifData::CompressionService.new.label(comp)) : super
          end

          # file.create_date
          # date_created
          def date_created
            date = @iiif_exif&.dig('fields',"DateTime")
            date.present? ? Array(Date.parse(date.split(' ').first.gsub(':','-')).strftime("%Y-%m-%d")) : super
          end

          def description
            preparations = @slide_json["http://rs.tdwg.org/dwc/terms/preparations"]
            preparations.present? ? Array(JSON.parse(preparations).map{|k,v| k.dup.concat(': ').concat(v)}.join(', ')) : super
          end

          # file_name
          def file_name
            @iiif_json&.dig("originalFilename") || super
          end

          # file_size
          def file_size
            @iiif_json&.dig("fileSize") || super
          end

          def fileset_accessibility
            ["open"]
          end

          # height
          def height
            @iiif_json&.dig("height")&.to_s || super
          end

          # identifier
          #["5c454d3c70aaa9064404a300"]
          def identifier
            Array(iiif_base_uri.split('/').last)
          end

          def imaging_description
            description = @iiif_exif&.dig("fields","ImageDescription")
            description.present? ? Array(description) : super
          end

          # license
          #["http://creativecommons.org/licences/by-nc-sa/3.0/"]
          # do not use mcz license - hardcode
          def license
            # lic = @slide_json["http://ns.adobe.com/xap/1.0/rights/WebStatement"]
            # lic.present? ? Array(lic) : super
            super
          end

          # mime_type
          def mime_type
            # if file_name.present?
            #   Rack::Mime.mime_type(File.extname(file_name))
            # else
            #   super
            # end
            "image/jpeg"
          end

          # pixel_spacing
          def pixel_spacing
            if x_spacing.present? && y_spacing.present?
              Array("#{x_spacing.first} \\ #{y_spacing.first}")
            else
              super
            end
          end

          # publisher
          def publisher
            ["Museum of Comparative Zoology, Harvard University"]
          end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742"]
          def related_url
            ref = @slide_json["http://purl.org/dc/terms/identifier"]
            ref.present? ? Array(ref) : super
          end

          # rights_holder
          #["Museum of Comparative Zoology, Harvard University"]
          def rights_holder
            rh = @json["rightsHolder"]
            rh.present? ? Array(rh) : super
          end

          def scanning_software
            software = @iiif_exif&.dig('fields',"Software")
            software.present? ? Array(software) : super
          end

          # short_description
          #["HEC-1009 Slide A"]
          def short_description
            description = @slide_json["http://purl.org/dc/terms/description"]
            description.present? ? Array(description) : super
          end

          # title
          #["HEC-1009 Slide A [Image]"]
          def title
            short_description.present? ? Array("#{short_description.first} [Image]") : super
          end

          # unit
          # See https://exiftool.org/TagNames/EXIF.html
          def unit
            ru = @iiif_exif&.dig("ResolutionUnit")
            ru.present? ? Array(Morphosource::ExifData::ResolutionUnitService.new.label(ru)) : super
          end

          def visibility
            'open'
          end

          # width
          def width
            w = @iiif_json&.dig("width")&.to_s
            w.present? ? w : super
          end

          # x_spacing
          def x_spacing
            denominator = @iiif_exif&.dig('fields',"XResolution","denominator")&.to_f
            numerator = @iiif_exif&.dig('fields',"XResolution","numerator")&.to_f
            if denominator && numerator
              Array("%f" % (denominator/numerator))
            else
              super
            end
          end

          # y_spacing
          def y_spacing
            denominator = @iiif_exif&.dig('fields',"YResolution","denominator")&.to_f
            numerator = @iiif_exif&.dig('fields',"YResolution","numerator")&.to_f
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
